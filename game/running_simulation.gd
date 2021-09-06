extends Spatial

const Simulator = preload("res://game/simulator.gd")

export(NodePath) var world_node_path
onready var world_node = get_node(world_node_path)
export(NodePath) var gui_node_path
onready var gui_node = get_node(gui_node_path)

var store: GameStore
var sim: Simulator
var simulator_state = "loading" setget set_simulator_state
func set_simulator_state(new_state):
  if simulator_state != new_state:
    simulator_state = new_state
    Events.emit_signal("simulator_state_updated", simulator_state)


func _ready():
  assert(store, "store required before _ready")

  world_node.store = store
  gui_node.store = store
  sim = Simulator.new(store)
  # self.simulator_state = "simulating"


func _input(event):
  if event.is_action_pressed("ui_select"):
    set_pause(not get_tree().paused)


func set_pause(new_paused):
  get_tree().paused = new_paused
  self.simulator_state = "paused" if new_paused else "simulating"


func _process(delta):
  match simulator_state:
    "simulating": if sim: sim._process(delta)
