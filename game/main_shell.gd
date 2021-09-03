extends Node

### Lazy Loaded Scenes ###
var RunningSimulation: PackedScene = null
func lazy_load_running_simulation():
  if not RunningSimulation:
    RunningSimulation = load("res://game/running_simulation.tscn")

  return RunningSimulation.instance()


var ScenarioEditor: PackedScene = null
func lazy_load_scenario_editor():
  if not ScenarioEditor:
    ScenarioEditor = load("res://game/gui/3d/scenario_editor/scenario_editor.tscn")

  return ScenarioEditor.instance()


### Eager Load and Remember Loading Scene ###
var loading_scene = preload("res://game/loading.tscn").instance()


### Grasp Node Collaborators ###
export(NodePath) var main_menu_path
onready var main_menu = get_node(main_menu_path)


### Track Our Currently Focused Scene ###
var current_scene


func _ready():
  # try function injection
  main_menu.receive_state_for_save = funcref(self, "provide_state_for_save")

  load_world(StateGenerator.state_from_template())
  # new_world()


func _input(event):
  if event.is_action_pressed("ui_cancel"):
    if main_menu.main_menu.visible:
      main_menu.main_menu.visible = false
    else:
      if current_scene and current_scene.has_method("set_pause"):
        current_scene.set_pause(true)
      main_menu.popup()


### Scene Management ###
func transition_to(scene):
  if current_scene:
    if current_scene == loading_scene:
      remove_child(current_scene)
    else:
      current_scene.queue_free()

  current_scene = scene
  add_child(current_scene)
  yield(get_tree(), "idle_frame")


func transition_to_loading():
  if not current_scene == loading_scene:
    yield(transition_to(loading_scene), "completed")
  else: yield(get_tree(), "idle_frame")


### Actions ###
func provide_state_for_save():
  printerr("provide_state_for_save not implemented")
  return Resource.new()


func load_world(state):
  main_menu.hide()
  yield(transition_to_loading(), "completed")

  var store = GameStore.new(state)
  var simulation = lazy_load_running_simulation()
  simulation.store = store

  yield(transition_to(simulation), "completed")


func new_world():
  main_menu.hide()
  yield(transition_to_loading(), "completed")

  var scenario_editor = lazy_load_scenario_editor()
  scenario_editor.connect("load_world_requested", self, "load_world")
  transition_to(scenario_editor)


func quit():
  # TODO: check important things and prompt only as appropriate
  get_tree().quit() # ruthlessly bail like the gods intended
