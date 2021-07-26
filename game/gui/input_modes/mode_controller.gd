extends Object
class_name ModeController

var game_state

func _init(new_game_state):
  game_state = new_game_state


func cell_left_clicked(_cell):
  printerr("%s Didn't implement cell_left_clicked" % self)


# by default let right click bail out to the basic selection mode
func cell_right_clicked(_cell):
  game_state.gui_state.mode = { "mode": Enums.Mode.SELECT }


func execute():
  printerr("%s Didn't implement execute" % self)


func remove_job_markers():
  printerr("%s Didn't implement remove_job_markers" % self)


func get_job_markers_between(_x1z1, _x2z2) -> Array:
  printerr("%s Didn't implement get_job_markers_between" % self)
  return []
