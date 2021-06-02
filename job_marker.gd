extends Spatial

var job

func _ready():
  assert(job, "JobMarker became ready without a job")
  translation = job.map_cell.position
  scale.x = clamp(job.percent_complete/100.0, 0.1, 1.0)
  job.connect("updated", self, "_job_updated")

func _job_updated(_updated_job):
  var target_scale = clamp(job.percent_complete/100.0, 0.1, 1.0)
  $Tween.interpolate_property(self, "scale",
    self.scale, Vector3(target_scale, self.scale.y, self.scale.z), 1,
    Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
  $Tween.start()
