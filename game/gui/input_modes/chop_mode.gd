extends ModeController
class_name ChopMode


func _init(game_state).(game_state): pass


func cell_left_clicked(cell):
  game_state.add_job(
    ChopJob.new({ "location": cell.location })
  )


func execute():
  print("TODO")


func remove_job_markers():
  print("TODO")


func get_job_markers_between(_x1z1, _x2z2) -> Array:
  print("TODO")
  return []
