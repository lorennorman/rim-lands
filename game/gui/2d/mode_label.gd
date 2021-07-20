extends Label

var current_mode
var current_simulator_state: String

func _ready():
  Events.connect("mode_updated", self, "mode_updated")
  Events.connect("simulator_state_updated", self, "simulator_state_updated")

func mode_updated(mode_change):
  current_mode = mode_change.mode
  update_text()

func simulator_state_updated(simulator_state):
  current_simulator_state = simulator_state
  update_text()

func update_text():
  var label = ""

  match current_mode:
    Enums.Mode.BUILD:
      label = "Build Where?"
    Enums.Mode.CHOP:
      label = "Chop Where?"
    _:
      label = "Select Something..."

  if current_simulator_state == "paused":
    label = "[P] %s" % label

  text = label
