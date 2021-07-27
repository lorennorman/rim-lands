extends ModeController
class_name ChopMode


# func _init(game_state).(game_state): pass


func confirm(cell):
  print("confirm chop")
  game_state.add_job(
    ChopJob.new({ "location": cell.location })
  )


func confirm_from_to(_start, _end):
  print("TODO")


# func remove_job_markers():
#   print("TODO")
#
#
# func get_job_markers_between(_x1z1, _x2z2) -> Array:
#   print("TODO")
#   return []
