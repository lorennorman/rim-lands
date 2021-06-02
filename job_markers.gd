extends Spatial

const JobMarker = preload("res://job_marker.tscn")

var job_markers = {}

func _ready():
  var _ja = Events.connect("job_added", self, "_on_job_added")
  var _jr = Events.connect("job_removed", self, "_on_job_removed")


func _on_job_added(job):
  var job_marker = JobMarker.instance()
  job_marker.job = job
  job_markers[job.key] = job_marker
  add_child(job_marker)


func _on_job_removed(job):
  if not job_markers.has(job.key): return
  var job_marker = job_markers[job.key]
  job_markers.erase(job.key)
  remove_child(job_marker)
  job_marker.queue_free()
