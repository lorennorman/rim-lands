extends Job
class_name HaulJob


func _init(mass_assignments: Dictionary = {}):
  mass_assignments["job_type"] = Enums.Jobs.HAUL
  ._init(mass_assignments)


func can_be_completed(): return true
