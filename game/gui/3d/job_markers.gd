extends Spatial

const JobMarker = preload("res://game/gui/3d/job_marker.tscn")

var job_markers = {}

func _ready():
  Events.connect("job_added", self, "_on_job_added")
  Events.connect("job_removed", self, "_on_job_removed")
  Events.connect("game_state_teardown", self, "teardown")


func _on_job_added(job):
  var job_marker = JobMarker.instance()
  job_marker.job = job
  job_markers[job.key] = job_marker
  add_child(job_marker)


func _on_job_removed(job):
  if not job_markers.has(job.key): return
  var job_marker = job_markers[job.key]
  job_markers.erase(job.key)
  job_marker.queue_free()


func teardown():
  for job_marker in job_markers.values(): job_marker.queue_free()
  job_markers.clear()
