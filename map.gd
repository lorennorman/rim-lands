# I generate terrain by scripting the HTerrain plugin! I bring a few special
# tools of my own, like the gradient-based terrain coloration, height weighting,
# a pathfinding grid, and a collection on each pathfinding node
tool
extends Spatial

# Utils
const Util = preload("res://util.gd")

# Import HTerrain classes
const HTerrain = preload("res://addons/zylann.hterrain/hterrain.gd")
const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")

# Import Game Map classes
const MapCell = preload("res://map_cell.tscn")

const Pawn = preload("res://pawn.gd")

# Terrain Size
export(int, 65,513) var terrain_size = 65
# Set noise-based color gradient in the editor
export(Gradient) onready var terrain_height_color_map
# Set noise-based elevation gradient in the editor
export(Gradient) onready var terrain_height_scale_map
# How high the highest theoretical mountain can be
export(float) var maximum_height = 25.0
# How large each individual cell on the map is
export(Vector3) var map_scale = Vector3(1, 1, 1)
var map_width
var map_height

# Noise Generator stuff
export(bool) var use_random_noise_seed = false
export(int) var noise_seed = 0
export(float, 0.001, 1000) var scale_grid_to_noise = 1
onready var noise = OpenSimplexNoise.new()

# For teh randoms
onready var rng = RandomNumberGenerator.new()

var map_grid
# Pathfinding graph
var astar = AStar.new()
var astar_lookup_table = {}
var grid_bags = {}


func set_pawn(index, pawn, force=false):
  # cell lookup
  var map_cell = map_grid.lookup_cell(index)

  # bail if exists and we're not forcing
  if map_cell.pawn and not force:
    return false

  # set or force-evict
  map_cell.pawn = pawn
  pawn.location = index
  pawn.map_cell = map_cell
  return true

# Camera's perspective to use when clicked
var input_camera

func _ready():
  if not use_random_noise_seed:
    noise.seed = noise_seed
  else:
    rng.randomize()
    noise.seed = rng.randf_range(-1000.0, 1000.0)

  # Generate fresh terrain
  var terrain_data = HTerrainData.new()

  # power-of-two-plus-1 (17, 33, 65, 129, 257, 513, 1025, etc...)
  terrain_data.resize(terrain_size)

  var image_maps = [HTerrainData.CHANNEL_COLOR, HTerrainData.CHANNEL_HEIGHT] #, HTerrainData.CHANNEL_NORMAL, HTerrainData.CHANNEL_DETAIL]
  extract_map_images(terrain_data, image_maps, funcref(self, "generate_maps"))

  var terrain = HTerrain.new()
  terrain.map_scale = map_scale
  terrain.set_shader_type(HTerrain.SHADER_LOW_POLY)
  terrain.set_data(terrain_data)
  terrain.update_collider() # super important if you want to click the terrain
  $Water.mesh.size = Vector2(terrain_size, terrain_size)
  $Water.translation = Vector3(terrain_size/2, 14.5, terrain_size/2)
  add_child(terrain)

func generate_maps(maps):
  # extract the maps to work with
  var color_map: Image = maps[0]
  var height_map: Image = maps[1]
  # var normal_map: Image = maps[2]
  # var detailmap: Image = maps[3]

  map_width = height_map.get_width()
  map_height = height_map.get_height()

  # Prepare the game data grid
  map_grid = MapGrid.new(map_width, map_height)

  # Prepare the pathfinding
  astar.reserve_space(map_width + map_height)

  for z in map_height:
    for x in map_width:
      # var node_key = "%s,%s" % [x, z]
      var nx = (x * scale_grid_to_noise)
      var nz = (z * scale_grid_to_noise)

      # returns in the range [-1, 1]
      var base_noise = noise.get_noise_2d(nx, nz)

      # var h_right = noise.get_noise_2d(nx + scale_grid_to_noise/10, nz)
      # var h_forward = noise.get_noise_2d(nx, nz + scale_grid_to_noise/10)
      # var normal = Vector3(base_noise - h_right, scale_grid_to_noise/10, h_forward - base_noise).normalized()

      # Normalize to the range [0, 1]
      var normalized_noise = inverse_lerp(-1, 1, base_noise)

      # height is provided to HTerrainData on the red channel
      var height = height_from_noise(x, z, normalized_noise)
      var height_color = Color(height, 0, 0)
      height_map.set_pixel(x, z, height_color)
      var color = color_from_noise(x, z, normalized_noise)
      color_map.set_pixel(x, z, color)
      # normal_map.set_pixel(x, z, HTerrainData.encode_normal(normal))
#      var detail_weight = detail_weight_from_noise(x, z, normalized_noise)
#      var detail_color = Color(detail_weight, 0, 0)
#      detailmap.set_pixel(x, z, detail_color)

      add_map_grid_cell(x, z, height, height_map, color)

      # add_pathfinding_node(x, z, height, height_map)
      # initialize_grid_bag(node_key, { "terrain": color })

func add_map_grid_cell(x, z, height, height_map, color):
  # calculate navigability
  var lowest_navigable_height = 0.332 * maximum_height
  var highest_navigable_height = 0.42 * maximum_height
  var is_navigable = (height > lowest_navigable_height) and (height < highest_navigable_height)

  # calculate exact 3d position
  var average_height
  if x == 0 or z == 0:
    average_height = height
  else:
    var old_height = height_map.get_pixel(x-1, z-1).r
    average_height = (height + old_height) / 2
  var position = Vector3((x-0.5), average_height, (z-0.5))
  # var position = Vector3((x-0.5), average_height, (z-0.5))

  map_grid.add_map_cell(position, x-1, z-1, color, !is_navigable)


func get_move_path(from_key, to_key):
  var from_id = map_grid.lookup_cell(from_key).astar_id
  var to_id = map_grid.lookup_cell(to_key).astar_id
  return map_grid.astar.get_point_path(from_id, to_id)

var to_process = null
var ray_length = 1000

func _input(event):
  if input_camera and (event is InputEventMouseButton and event.pressed) or (event is InputEventMouseMotion):
    # cast ray from the given camera
    var from = input_camera.project_ray_origin(event.position)
    var to = from + input_camera.project_ray_normal(event.position) * ray_length

    var action = "hovered" # default so we don't have to check for MouseMotion
    if event is InputEventMouseButton:
      if event.button_index == 1:
        action = "lclicked"
      if event.button_index == 2:
        action = "rclicked"

    if from and to:
      self.to_process = { "from": from, "to": to, "action": action }

func _physics_process(_delta):
  if to_process:
    # get the physical world
    var space_state = get_world().direct_space_state
    # unpack the job
    var from = to_process["from"]
    var to = to_process["to"]
    var action = to_process["action"]
    # do the work
    var result = space_state.intersect_ray(from, to)
    # clear the job
    to_process = null

    # if the work worked, go!
    if result.get("position"):
      var node_key = "%d,%d" % [result.position.x, result.position.z]
      Events.emit_signal("node_%s" % action, node_key)

    if result.get("collider") and result.collider is Pawn:
      print(result.collider)

func height_from_noise(_x, _z, noise_value):
  # map our noise to the supplied grayscale gradient, easy height scale mutation
  var height_color = terrain_height_scale_map.interpolate(noise_value)
  # any channel should do but pull out red (following HTerrain's convention)
  var height = height_color.r * maximum_height

  # or just do a simple height modifier
  #  var height = maximum_height * noise

  return height

func color_from_noise(_x, _z, noise_value):
  # Use a Gradient to match color to elevation (easy to edit in the editor)
  var color = terrain_height_color_map.interpolate(noise_value)
  return color

# func detail_from_noise(x, z, detail_noise):
#   # Generate Grass from the noise
#   var detailWeight = clamp(inverse_lerp(.1, 0, abs(detail_noise - .5)), 0.0, 1.0)

# this is all hterrain implementation details
func extract_map_images(terrain_data, image_types, operator_func):
  var images = []
  for image_type in image_types:
    var image_map: Image = terrain_data.get_image(image_type)
    image_map.lock()
    images.append(image_map)

  operator_func.call_func(images)

  for image in images:
    image.unlock()

  var modified_region = Rect2(Vector2(), images[0].get_size())
  for image_type in image_types:
    terrain_data.notify_region_change(modified_region, image_type)
