extends CanvasItem

## Jobs
var JobLabel = preload("res://game/gui/2d/job_label.gd")
var job_labels = {}

func _ready():
  Events.connect("job_added", self, "job_added")
  Events.connect("job_removed", self, "job_removed")
  Events.connect("game_state_teardown", self, "teardown")


func job_added(job):
  var job_label = JobLabel.new(job)
  job_labels[job.key] = job_label
  add_child(job_label)


func job_removed(job):
  if not job_labels.has(job.key): return
  var job_label = job_labels[job.key]
  job_labels.erase(job.key)
  job_label.queue_free()


func teardown():
  for job_label in job_labels.values(): job_label.queue_free()
  job_labels.clear()
