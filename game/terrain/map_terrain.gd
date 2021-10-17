# I generate terrain by scripting the HTerrain plugin! I bring a few special
# tools of my own, like the gradient-based terrain coloration, elevation curve,
# a pathfinding grid, and a collection on each pathfinding node
extends Spatial

# Import HTerrain classes
const HTerrain = preload("res://addons/zylann.hterrain/hterrain.gd")
const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")

var terrain: HTerrain
export(float) var water_y = 10.65

# Camera's perspective to use when clicked
export(NodePath) var input_camera_node_path
onready var input_camera: Camera = get_node(input_camera_node_path)
var input_state = "paused"


var store setget set_store
var map
func set_store(new_store):
  input_state = "paused"

  clear_existing_terrain()
  store = new_store
  map = store.map
  generate_from_map()

  input_state = "listening"


func clear_existing_terrain():
  if terrain:
    printerr("Terrain already present")
    terrain.queue_free()
    terrain = null


func generate_from_map():
  assert(map, "Tried to generate MapTerrain without a Map")
  assert(!terrain, "Tried to generate MapTerrain without clearing previous terrain")

  # Generate fresh terrain
  var terrain_data = HTerrainData.new()
  # only valid options: 65, 129, 257, 513, 1025, 2049
  terrain_data.resize(map.size)

  var image_maps = [HTerrainData.CHANNEL_COLOR, HTerrainData.CHANNEL_HEIGHT] #, HTerrainData.CHANNEL_NORMAL, HTerrainData.CHANNEL_DETAIL]
  extract_map_images(terrain_data, image_maps, funcref(self, "generate_maps"))

  terrain = HTerrain.new()
  terrain.set_shader_type(HTerrain.SHADER_LOW_POLY)
  terrain.set_data(terrain_data)
  terrain.update_collider() # super important if you want to click the terrain

  # calibrate/hide water
  if map.environment.name == "Core's Edge":
    $Water.visible = true
    $Water.mesh.size = Vector2(map.size, map.size)
    $Water.translation = Vector3(map.size/2, water_y, map.size/2)
  else:
    $Water.visible = false

  add_child(terrain)


func generate_maps(maps):
  # extract the maps to work with
  var color_map: Image = maps[0]
  var height_map: Image = maps[1]

  for z in height_map.get_width():
    for x in height_map.get_height():
      var map_cell = map.lookup_cell("%d,%d" % [x, z])
      var height_color = Color(map_cell.position.y, 0, 0)
      height_map.set_pixel(x, z, height_color)
      color_map.set_pixel(x, z, map_cell.terrain)


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


# Mouse Input Tracking
var to_process = null
var ray_length := 1000
var left_dragging := false
var right_dragging := false
func _unhandled_input(event):
  if input_state != "listening": return

  if event is InputEventMouseButton:
    if event.button_index == 1:
      if left_dragging != event.pressed:
        if event.pressed:
          Events.emit_signal("left_drag_started")
        else:
          Events.emit_signal("left_drag_ended")
      left_dragging = event.pressed
    elif event.button_index == 2:
      if right_dragging != event.pressed:
        if event.pressed:
          Events.emit_signal("right_drag_started")
        else:
          Events.emit_signal("right_drag_ended")
      right_dragging = event.pressed

  if input_camera and (event is InputEventMouseButton and event.pressed) or (event is InputEventMouseMotion):
    # cast ray from the given camera
    var from = input_camera.project_ray_origin(event.position)
    var to = from + input_camera.project_ray_normal(event.position) * ray_length

    var action = "hovered" # default so we don't have to check for MouseMotion
    if event is InputEventMouseButton:
      if event.button_index == 1:
        action = "left_clicked"
      if event.button_index == 2:
        action = "right_clicked"

    if from and to:
      self.to_process = { "from": from, "to": to, "action": action }

func _physics_process(_delta):
  if to_process:
    if input_state != "listening":
      # state changed, forget everything
      to_process = null
      return
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
      var location = "%d,%d" % [result.position.x, result.position.z]
      var map_cell = map.lookup_cell(location)
      Events.emit_signal("cell_%s" % action, map_cell)

    if result.get("collider") and result.collider is Pawn:
      print(result.collider)
