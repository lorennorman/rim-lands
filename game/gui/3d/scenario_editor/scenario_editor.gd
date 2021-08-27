extends Control

signal load_world_requested

export(NodePath) var map_terrain_path
export(NodePath) var camera_path
export(NodePath) var environment_control_path
export(NodePath) var map_size_control_path
export(NodePath) var terrain_seed_control_path

onready var map_terrain = get_node(map_terrain_path)
onready var camera = get_node(camera_path)
onready var environment_control = get_node(environment_control_path)
onready var map_size_control = get_node(map_size_control_path)
onready var terrain_seed_control = get_node(terrain_seed_control_path)

onready var rng := RandomNumberGenerator.new()

export(Resource) var state setget set_state
func set_state(new_state):
  state = new_state
  map_grid = state.map_grid


export(Resource) var map_grid


func _ready():
  prepare_state()


func prepare_state(given_state = null):
  if given_state:
    self.state = given_state
  elif not state:
    self.state = StateGenerator.state_from_template()

  state.map_grid.astar = null
  StateActivator.activate_state(state)

  initialize_controls()
  map_terrain.map_grid = map_grid


func initialize_controls():
  for index in environment_control.get_item_count():
    if environment_control.get_item_text(index).find(map_grid.environment) != -1:
      environment_control.select(index)
      break

  for index in map_size_control.get_item_count():
    var item_text = map_size_control.get_item_text(index)
    if item_text.find(map_grid.map_size - 1) != -1:
      map_size_control.select(index)
      break

  terrain_seed_control.value = map_grid.terrain_seed


func environment_selected(item_index: int):
  var environment_name = environment_control.get_item_text(item_index)
  for key in StateGenerator.ENVIRONMENTS.keys():
    var env = StateGenerator.ENVIRONMENTS[key]
    if env.name == environment_name:
      map_grid.environment = key
      break

  prepare_state(state)


func map_size_selected(item_index: int):
  if map_size_control.is_item_disabled(item_index): return

  var size_name = map_size_control.get_item_text(item_index)
  var size = 65
  if size_name.find("128") != -1:
    size = 129
  # elif size_name.find("256") != -1:
  #   size = 257
  # elif size_name.find("512") != -1:
  #   size = 513

  if map_grid.map_size != size:
    camera.translation = Vector3(size/2, size*5/6, size/2)
    map_grid.map_size = size
    prepare_state(state)


func terrain_seed_changed(new_seed: int):
  map_grid.terrain_seed = new_seed
  prepare_state(state)


func randomize_terrain_seed():
  rng.randomize()
  map_grid.terrain_seed = rng.randi_range(-5_000_000, 5_000_000)
  terrain_seed_control.value = map_grid.terrain_seed
  prepare_state(state)


func start_game_pressed():
  emit_signal("load_world_requested", state)
