extends Spatial

const JobMarker = preload("res://job_marker.tscn")

func _ready():
  var _job_added = Events.connect("job_added", self, "_on_job_added")

func _on_job_added(job):
  var job_marker = JobMarker.instance()
  job_marker.job = job
  add_child(job_marker)
