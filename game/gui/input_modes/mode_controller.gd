extends Object
class_name ModeController

var game_state

func _init(new_game_state=null):
  game_state = new_game_state


func consider_from_to(_start, _end):
  printerr("%s Didn't implement consider_from_to" % self)


func confirm(_cell):
  printerr("%s Didn't implement confirm" % self)


# by default let right click bail out to the basic selection mode
func cancel(_cell):
  game_state.mode = { "mode": Enums.Mode.SELECT }


func confirm_from_to(_start, _end):
  printerr("%s Didn't implement consider_from_to" % self)
