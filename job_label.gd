extends Label

const Job = preload("res://job.gd")
var job

func _init(new_job):
  job = new_job

  job.connect("updated", self, "model_did_update")
  do_render()
  
func model_did_update(job):
  print("received update", str(job))
  do_render()

func do_render():
  var claim_status = "[x]" if job.is_claimed() else "[ ]"
  text = "%s %s @ %s" % [claim_status, job.name, job.location]
