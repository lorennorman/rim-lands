extends Label

const Job = preload("res://job.gd")
var job

func _init(new_job):
  job = new_job

  var _job_compeleted = Events.connect("job_completed", self, "check_completed")
  job.connect("updated", self, "model_did_update")
  do_render()

func model_did_update(_job):
  do_render()

func do_render():
  text = job.as_text()

func check_completed(completed_job):
  if job == completed_job:
    queue_free()
