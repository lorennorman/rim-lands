extends Job
class_name HaulJob

var material
var quantity

func _init(mass_assignments: Dictionary = {}):
  mass_assignments["job_type"] = Enums.Jobs.HAUL
  ._init(mass_assignments)

  assert(parent, "HaulJob created without a parent Job.")
  assert(material != null, "HaulJob created without a material.")
  assert(quantity != null, "HaulJob created without a quantity.")
