extends Node

onready var RunningSimulation = load("res://game/running_simulation.tscn")
onready var main_menu = $CanvasLayer/MainMenu
# preload and keep in memory Loading scene
var loading_scene = preload("res://game/loading.tscn").instance()

var current_scene

func _ready():
  # try function injection
  main_menu.receive_state_for_save = funcref(self, "provide_state_for_save")

  new_world()

func _input(event):
  if event.is_action_pressed("ui_cancel"):
    if main_menu.main_menu.visible:
      main_menu.main_menu.visible = false
    else:
      if current_scene: current_scene.set_pause(true)
      main_menu.popup()


func provide_state_for_save():
  return "state!"


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


func load_world(state):
  yield(transition_to_loading(), "completed")

  StateActivator.activate_state(state)
  var simulation = RunningSimulation.instance()
  simulation.game_state = state

  transition_to(simulation)


func new_world():
  main_menu.main_menu.visible = false
  yield(transition_to_loading(), "completed")

  var state = StateGenerator.state_from_template()
  load_world(state)

  # replace the child app with a scenario generator
  # var new_map_grid = MapGrid.new()
  # new_map_grid.astar = null # initializes faster without the pathfinding network
  # new_map_grid.terrain_style = "Core's Edge"
  # ensure_map_viewer()
  # map_viewer.map_grid = new_map_grid


func quit():
  # TODO: check important things and prompt only as appropriate
  get_tree().quit() # ruthlessly bail like the gods intended
