extends Control

const DEFAULT_SCENARIO_PATH = "res://scenarios/standard_start_template.tres"
const PawnEditor = preload("res://game/gui/2d/pawn_editor/pawn_editor.tscn")

signal load_world_requested

export(NodePath) var map_terrain_path
export(NodePath) var camera_path
export(NodePath) var environment_control_path
export(NodePath) var map_size_control_path
export(NodePath) var terrain_seed_control_path
export(NodePath) var forest_seed_control_path
export(NodePath) var pawn_editors_path

onready var map_terrain = get_node(map_terrain_path)
onready var camera = get_node(camera_path)
onready var environment_control = get_node(environment_control_path)
onready var map_size_control = get_node(map_size_control_path)
onready var terrain_seed_control = get_node(terrain_seed_control_path)
onready var forest_seed_control = get_node(forest_seed_control_path)
onready var pawn_editors = get_node(pawn_editors_path)

onready var rng := RandomNumberGenerator.new()

var current_template
var state
var map_grid


func _ready():
  rng.randomize()

  load_template(DEFAULT_SCENARIO_PATH)


func load_template(template_path):
  current_template = ResourceLoader.load(template_path, "Resource", false)

  update_state()


func update_state():
  Events.emit_signal("game_state_teardown")
  # FIXME: godot remembers resource arrays between objects
  if map_grid: map_grid.forests.clear()

  # generate the state
  state = StateGenerator.state_from_template(current_template)
  map_grid = state.map_grid
  # remove the pathfinding
  state.map_grid.astar = null
  # activate state for drawing
  StateActivator.activate_state(state)
  # ensure controls are up to date
  update_controls()
  # draw this thing
  map_terrain.map_grid = map_grid
  $HSplitContainer/VBoxContainer/MarginContainer2/CenterContainer/HBoxContainer/VBoxContainer2/Label2.text = "Forests: %s" % map_grid.forests.size()


func update_controls():
  # environment
  for index in environment_control.get_item_count():
    var env_item = environment_control.get_item_text(index)
    if env_item.findn(map_grid.environment) != -1:
      environment_control.select(index)
      break

  # map size
  for index in map_size_control.get_item_count():
    var item_text = map_size_control.get_item_text(index)
    if item_text.find(map_grid.map_size - 1) != -1:
      map_size_control.select(index)
      break

  # terrain seed
  terrain_seed_control.text = String(map_grid.terrain_seed)
  # forest seed
  forest_seed_control.text = String(current_template.map_template.forest_seed)

  for child in pawn_editors.get_children(): child.queue_free()

  for pawn in state.pawns:
    var pawn_editor = PawnEditor.instance()
    pawn_editor.pawn = pawn
    pawn_editors.add_child(pawn_editor)

  camera.translation = Vector3(map_grid.map_size/2, map_grid.map_size*5/6, map_grid.map_size/2)


func environment_selected(item_index: int):
  var environment_name = environment_control.get_item_text(item_index)
  for key in StateGenerator.ENVIRONMENTS.keys():
    var env = StateGenerator.ENVIRONMENTS[key]
    if env.name == environment_name:
      current_template.map_template.environment = key
      break

  update_state()


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
    current_template.map_template.map_size = size
    update_state()


func terrain_seed_changed(new_seed_text: String = ""):
  if new_seed_text == "":
    new_seed_text = terrain_seed_control.text

  var new_seed = int(new_seed_text)
  if new_seed:
    current_template.map_template.terrain_seed = new_seed
  else:
    current_template.map_template.terrain_seed = new_seed_text.hash()

  update_state()


# arbitrary random seed limit
const TWO_BILLION = 2_000_000_000
func randomize_terrain_seed():
  var new_seed = rng.randi_range(-TWO_BILLION, TWO_BILLION)
  current_template.map_template.terrain_seed = new_seed
  update_state()


func randomize_forest_seed():
  var new_seed = rng.randi_range(-TWO_BILLION, TWO_BILLION)
  current_template.map_template.forest_seed = new_seed
  update_state()


func start_game_pressed():
  emit_signal("load_world_requested", state)
