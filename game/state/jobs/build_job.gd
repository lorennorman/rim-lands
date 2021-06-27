extends Job

class_name BuildJob

func _init(mass_assignments: Dictionary = {}):
  mass_assignments["job_type"] = Enums.Jobs.BUILD
  ._init(mass_assignments)


func can_be_completed(): return false


func sub_jobs() -> Array:
  return [
    HaulJob.new({ "location": self.location }),
    HaulJob.new({ "location": self.location }),
    HaulJob.new({ "location": self.location }),
  ]
