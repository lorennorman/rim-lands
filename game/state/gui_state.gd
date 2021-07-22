extends Resource

class_name GUIState

func _init():
  Events.connect("set_mode", self, "set_mode")


var mode
# signal mode_updated
func set_mode(mode_params):
  mode = mode_params.mode
  Events.emit_signal("mode_updated", mode_params)
