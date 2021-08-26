extends Spatial

const Simulator = preload("res://game/simulator.gd")

var game_state: GameState
var sim: Simulator
var simulator_state = "loading" setget set_simulator_state
func set_simulator_state(new_state):
  if simulator_state != new_state:
    simulator_state = new_state
    Events.emit_signal("simulator_state_updated", simulator_state)


func _ready():
  $MapTerrain.input_camera = $Camera

  assert(game_state, "game_state required before _ready")

  $MapTerrain.map_grid = game_state.map_grid
  $MapTerrain.input_state = "listening"
  $GUI.game_state = game_state
  sim = Simulator.new(game_state)
  self.simulator_state = "simulating"


func _input(event):
  if event.is_action_pressed("ui_select"):
    set_pause(not get_tree().paused)


func set_pause(new_paused):
  get_tree().paused = new_paused
  simulator_state = "paused" if new_paused else "simulating"


func _process(delta):
  match simulator_state:
    "simulating": if sim: sim._process(delta)


# retire this now?
func duplicate_game_state(game_state_to_copy) -> GameState:
  # gets new()'d so we have a proper GameState class and our casting works
  var duplicated_game_state = GameState.new()
  # use duplicate() on the sub-resources
  # keep this up to date as sub-resources are added
  duplicated_game_state.pawns = []
  for pawn in game_state_to_copy.pawns:
    duplicated_game_state.pawns.push_back(pawn.duplicate())
  duplicated_game_state.jobs = []
  for job in game_state_to_copy.jobs:
    duplicated_game_state.jobs.push_back(job.duplicate())
  for building in game_state_to_copy.buildings:
    duplicated_game_state.buildings.push_back(building.duplicate())
  duplicated_game_state.map_grid = game_state_to_copy.map_grid.duplicate()

  return duplicated_game_state
