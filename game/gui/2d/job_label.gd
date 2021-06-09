extends Label

var job

func _init(new_job):
  job = new_job

  do_render()

func _ready():
  job.connect("updated", self, "model_did_update")

func model_did_update(_job):
  do_render()

func do_render():
  text = job.as_text()
