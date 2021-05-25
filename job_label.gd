extends Label

var job

func _init(new_job):
  job = new_job

  do_render()

func _ready():
  var _job_compeleted = Events.connect("job_completed", self, "check_completed")
  job.connect("updated", self, "model_did_update")

func model_did_update(_job):
  do_render()

func do_render():
  text = job.as_text()

func check_completed(completed_job):
  if job == completed_job:
    queue_free()
