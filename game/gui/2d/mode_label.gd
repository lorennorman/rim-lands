extends Label

func _ready():
  var _mu = Events.connect("mode_updated", self, "mode_updated")

func mode_updated(mode_change):
  match mode_change.mode:
    Enums.Mode.BUILD:
      text = "Mode: Build Orders"
    _:
      text = "Mode: Selection"
