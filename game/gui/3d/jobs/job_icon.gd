extends Spatial

var job setget set_job
func set_job(new_job):
  job = new_job
  translation = job.map_cell.position
  print(translation)
