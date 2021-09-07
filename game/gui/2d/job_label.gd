extends Label

var job


func _ready():
  job.connect("updated", self, "model_did_update")


func model_did_update(_job):
  text = job.as_text()
