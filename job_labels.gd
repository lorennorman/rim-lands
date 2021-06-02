extends CanvasItem

## Jobs
var JobLabel = preload("res://job_label.gd")
var job_labels = {}

func _ready():
  var _ja = Events.connect("job_added", self, "job_added")
  var _jr = Events.connect("job_removed", self, "job_removed")


func job_added(job):
  var job_label = JobLabel.new(job)
  job_labels[job.key] = job_label
  add_child(job_label)


func job_removed(job):
  if not job_labels.has(job.key): return
  var job_label = job_labels[job.key]
  job_labels.erase(job.key)
  remove_child(job_label)
  job_label.queue_free()
