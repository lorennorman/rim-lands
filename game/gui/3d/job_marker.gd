extends Spatial

const BuildingModel = preload("res://game/buildings/building_model.gd")

var job
var building_model


func calculate_scale(percent): return clamp(percent/100.0, 0.08, 1.0)


func _ready():
  assert(job, "JobMarker became ready without a Job")
  job.connect("updated", self, "_job_updated")

  match job.job_type:
    Enums.Jobs.BUILD:
      building_model = BuildingModel.new()
      building_model.cell = job.map_cell
      building_model.scale.y = calculate_scale(job.percent_complete)
      add_child(building_model)
    Enums.Jobs.HAUL:
      pass
    _: printerr("JobMarker created for unknown job_type: %s" % job.job_type)


func _job_updated(_updated_job):
  match job.job_type:
    Enums.Jobs.BUILD:
      var target_scale_y = calculate_scale(job.percent_complete)
      var target_scale = Vector3(building_model.scale.x, target_scale_y, building_model.scale.z)
      var how_many_seconds = .5 # ask the job how long this should be somehow?
      $Tween.interpolate_property(building_model, "scale", building_model.scale,
        target_scale, how_many_seconds, Tween.TRANS_EXPO, Tween.EASE_OUT)
      $Tween.start()
    Enums.Jobs.HAUL:
      pass
