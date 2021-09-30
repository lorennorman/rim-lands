extends Label

var job setget set_job
func set_job(new_job):
  job = new_job
  model_did_update()


func _ready():
  job.connect("updated", self, "model_did_update")


func model_did_update(_job=null):
  text = job.as_text()
