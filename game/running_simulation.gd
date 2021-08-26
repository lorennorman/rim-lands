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
  assert(game_state, "game_state required before _ready")

  $MapTerrain.input_camera = $Camera
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
  self.simulator_state = "paused" if new_paused else "simulating"


func _process(delta):
  match simulator_state:
    "simulating": if sim: sim._process(delta)
