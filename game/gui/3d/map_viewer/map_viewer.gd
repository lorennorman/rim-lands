extends Control

const MapTerrain = preload("res://game/terrain/map_terrain.tscn")

export(NodePath) var viewport_path
export(NodePath) var camera_path
export(NodePath) var style_control_path
export(NodePath) var size_control_path
export(NodePath) var seed_control_path
export(NodePath) var randomize_control_path
export(NodePath) var height_control_path
export(NodePath) var scale_control_path

onready var viewport = get_node(viewport_path)
onready var camera = get_node(camera_path)
onready var style_control = get_node(style_control_path)
onready var size_control = get_node(size_control_path)
onready var seed_control = get_node(seed_control_path)
onready var randomize_control = get_node(randomize_control_path)
onready var height_control = get_node(height_control_path)
onready var scale_control = get_node(scale_control_path)

onready var rng := RandomNumberGenerator.new()

export(Resource) var state setget set_state
func set_state(new_state):
  state = new_state
  map_grid = state.map_grid


export(Resource) var map_grid


func _ready():
  # User settings
  style_control.connect("item_selected", self, "terrain_style_item_selected")
  size_control.connect("item_selected", self, "terrain_size_item_selected")
  seed_control.connect("value_changed", self, "terrain_seed_changed")
  randomize_control.connect("pressed", self, "randomize_terrain_seed")

  prepare_state()

func prepare_state(given_state = null):
  if given_state:
    self.state = given_state
  else:
    self.state = StateGenerator.state_from_template()

  state.map_grid.astar = null
  StateActivator.activate_state(state)

  initialize_controls()
  set_map_grid_on_map_terrain()


func initialize_controls():
  for index in style_control.get_item_count():
    if style_control.get_item_text(index).find(map_grid.environment) != -1:
      style_control.select(index)
      break

  for index in size_control.get_item_count():
    var item_text = size_control.get_item_text(index)
    if item_text.find(map_grid.map_size - 1) != -1:
      size_control.select(index)
      break

  seed_control.value = map_grid.terrain_seed
  height_control.value = StateGenerator.ENVIRONMENTS[map_grid.environment].height
  scale_control.value = StateGenerator.ENVIRONMENTS[map_grid.environment].scale


func set_map_grid_on_map_terrain():
  if not viewport: return
  var map_terrain = viewport.get_node_or_null("MapTerrain")

  if not map_terrain:
    map_terrain = MapTerrain.instance()
    viewport.add_child(map_terrain)
    map_terrain.owner = viewport

  # map_grid.generate_cells(true)
  map_terrain.map_grid = map_grid


func terrain_style_item_selected(item_index: int):
  var environment_name = style_control.get_item_text(item_index)
  for key in StateGenerator.ENVIRONMENTS.keys():
    var env = StateGenerator.ENVIRONMENTS[key]
    if env.name == environment_name:
      map_grid.environment = key
      break

  prepare_state(state)


func terrain_size_item_selected(item_index: int):
  if size_control.is_item_disabled(item_index): return

  var size_name = size_control.get_item_text(item_index)
  var size = 65
  if size_name.find("128") != -1:
    size = 129
  # elif size_name.find("256") != -1:
  #   size = 257
  # elif size_name.find("512") != -1:
  #   size = 513

  if map_grid.map_size != size:
    camera.translation = Vector3(size/2, camera.translation.y, size/2)
    map_grid.map_size = size
    prepare_state(state)


func terrain_seed_changed(new_seed: int):
  map_grid.terrain_seed = new_seed
  prepare_state(state)


func randomize_terrain_seed():
  rng.randomize()
  map_grid.terrain_seed = rng.randi_range(-5000,5000)
  seed_control.value = map_grid.terrain_seed
  prepare_state(state)


signal close_window
func start_game_pressed():
  cleanup_and_close()
  Events.emit_signal("new_game_requested", map_grid)


func cancel_pressed():
  cleanup_and_close()


func cleanup_and_close():
  var map_terrain = viewport.get_node_or_null("MapTerrain")
  if map_terrain:
    map_terrain.queue_free()

  emit_signal("close_window")
