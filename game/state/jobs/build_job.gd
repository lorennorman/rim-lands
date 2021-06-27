extends Job
class_name BuildJob


var building_type

var materials_required: Dictionary = {} setget set_materials_required
func set_materials_required(new_materials):
  materials_required = new_materials
  for material in materials_required:
    materials_present[material] = 0

var materials_present: Dictionary = {}

func set_params(new_params):
  building_type = new_params


func _init(mass_assignments: Dictionary = {}):
  mass_assignments["job_type"] = Enums.Jobs.BUILD
  ._init(mass_assignments)

  assert(building_type != null, "BuildJob created without a building_type.")

  var lacking_materials = get_lacking_materials()
  for material in lacking_materials:
    sub_jobs.push_back(
      HaulJob.new({
        "location": self.location,
        "material": material,
        "quantity": lacking_materials[material]
      }))


func get_lacking_materials():
  var lacking = {}
  for material in materials_required:
    var quantity = materials_required[material] - materials_present[material]
    if quantity > 0:
      lacking[material] = quantity

  return lacking

func can_be_completed():
  return sub_jobs.size() <= 0
