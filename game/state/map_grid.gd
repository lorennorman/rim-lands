extends Resource

class_name MapGrid

# The size of the length and width (maps are always square)
export(int) var map_size = 129
# How high the highest theoretical mountain can be
export(float) var maximum_height = 35.0
# Set noise-based color gradient in the editor
# var terrain_height_color_map: Gradient = preload("res://game/terrain/res/height_color_gradient.tres")
var terrain_height_color_map: Gradient = preload("res://game/terrain/res/voidlands_color_gradient.tres")
# Elevation Curve
# var terrain_elevation_curve: Curve = preload("res://game/terrain/res/elevation_curve.tres")
var terrain_elevation_curve: Curve = preload("res://game/terrain/res/voidlands_elevation_curve.tres")


# Noise Generator stuff
export(int) var noise_seed = 2
export(float, 0.001, 1000) var scale_grid_to_noise = 1.25
var noise: OpenSimplexNoise

var astar: AStar
var omni_dict: Dictionary

var torndown = false


func generate_cells():
  astar = AStar.new()
  astar.reserve_space(map_size * map_size)

  omni_dict = {}

  noise = OpenSimplexNoise.new()
  noise.seed = noise_seed

  for z in map_size:
    for x in map_size:
      var nx = (x * scale_grid_to_noise)
      var nz = (z * scale_grid_to_noise)

      # returns in the range [-1, 1]
      var base_noise = noise.get_noise_2d(nx, nz)

      # Normalize to the range [0, 1]
      var normalized_noise = inverse_lerp(-1, 1, base_noise)

      # height is provided to HTerrainData on the red channel
      var height = height_from_noise(x, z, normalized_noise)
      # height_map.set_pixel(x, z, height_color)
      var color = color_from_noise(x, z, normalized_noise)
      # color_map.set_pixel(x, z, color)

      add_map_grid_cell(x, z, height, color)


func add_map_grid_cell(x, z, height, color):
  # calculate navigability
  var lowest_navigable_height = 0.332 * maximum_height
  var highest_navigable_height = 0.42 * maximum_height
  var is_navigable = (height > lowest_navigable_height) and (height < highest_navigable_height)

  # calculate exact 3d position
  var average_height
  if x == 0 or z == 0:
    average_height = height
  else:
    var old_height = lookup_cell("%d,%d" % [x-1, z-1]).position.y #height_map.get_pixel(x-1, z-1).r
    average_height = (height + old_height) / 2
  var position = Vector3((x+0.5), average_height, (z+0.5))

  add_map_cell(position, x, z, color, !is_navigable)


func height_from_noise(_x, _z, noise_value):
  # Simple: amplify noise value to a maximum
  # var height = maximum_height * noise_value

  # Tool: Use a Curve to draw the contour of your terrain
  var height = maximum_height * terrain_elevation_curve.interpolate(noise_value)

  return height


func color_from_noise(_x, _z, noise_value):
  # Use a Gradient to match color to elevation (easy to edit in the editor)
  var color = terrain_height_color_map.interpolate(noise_value)
  return color


func lookup_cell(omni_id):
  if torndown:
    printerr("lookup_cell called after torndown at: %s" % omni_id)
    return MapCell.new()

  assert(omni_dict.has(omni_id), "Omni Dict doesn't have ID: '%s'" % omni_id)
  return omni_dict[omni_id]


func set_cell(omni_id, cell):
  omni_dict[omni_id] = cell


func set_pawn(location: String, pawn: Pawn, force=false):
  # cell lookup
  var map_cell: MapCell = lookup_cell(location)

  # bail if exists and we're not forcing
  if map_cell.pawn and not force: return false

  # set or force-evict
  map_cell.pawn = pawn
  pawn.location = location
  pawn.map_cell = map_cell
  return true


func add_map_cell(position, x, z, terrain, disabled=false):
  var map_cell = MapCell.new()

  # Supply the map to query
  map_cell.map_grid = self

  # Apply the terrain
  map_cell.terrain = terrain
  map_cell.disabled = disabled

  # Store and index position
  map_cell.position = position
  set_cell(position, map_cell)

  # Generate, store, and index location key
  var location_key = "%d,%d" % [x, z]
  map_cell.location = location_key
  set_cell(location_key, map_cell)

  # Generate astar id and connect to the pathfinding grid
  var astar_id = astar.get_available_point_id()
  astar.add_point(astar_id, position)
  add_astar_connections(astar_id, x, z)
  if map_cell.disabled:
    astar.set_point_disabled(astar_id, true)

  # Store and index astar id
  map_cell.astar_id = astar_id
  set_cell(astar_id, map_cell)

  map_cell.connect("pathing_updated", self, "pathing_updated")


func pathing_updated(astar_id: int, pathable: bool):
  astar.set_point_disabled(astar_id, !pathable)


func add_astar_connections(astar_id, x, z):
  # Connect up, left, upper-left, and upper-right
  # Note: expects cells to be added LtR
  if z > 0:
    add_astar_connection(astar_id, "%d,%d" % [x, z-1]) # up
  if x > 0:
    add_astar_connection(astar_id, "%d,%d" % [x-1, z]) # left
  if x > 0 and z > 0:
    add_astar_connection(astar_id, "%d,%d" % [x-1, z-1]) # upleft
  if z > 0 and x < map_size - 2:
    add_astar_connection(astar_id, "%d,%d" % [x+1, z-1]) # upright


func add_astar_connection(astar_id, location_key):
  var cell = lookup_cell(location_key)
  # Blow up if we get something we don't expect
  assert(cell, "No connection found between AStar ID: %s and Location %s" % [astar_id, location_key])
  assert(cell.astar_id != astar_id, "Cannot connect AStar node to itself: %s" % astar_id)
  assert(not astar.are_points_connected(astar_id, cell.astar_id), "AStar IDs already connected: %s, %s" % [astar_id, cell.astar_id])

  astar.connect_points(astar_id, cell.astar_id)


func get_move_path(from_key, to_key):
  var from_id = lookup_cell(from_key).astar_id if from_key is String else from_key.astar_id
  var to_id = lookup_cell(to_key).astar_id if to_key is String else to_key.astar_id
  return astar.get_point_path(from_id, to_id)


func teardown():
  omni_dict.clear() # clear the map cells
  astar.clear() # clear the astar network
  torndown = true
