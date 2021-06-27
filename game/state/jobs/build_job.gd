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


func get_lacking_materials():
  var lacking = {}
  for material in materials_required:
    var quantity = materials_required[material] - materials_present[material]
    if quantity > 0:
      lacking[material] = quantity

  return lacking


func add_materials(material):
  materials_present[material.type] += material.quantity
  dirty = true

var dirty = true
func ensure_sub_jobs():
  if not dirty: return
  var lacking_materials = get_lacking_materials()

  for material in lacking_materials:
    if find_haul_job_by_material(material): continue

    var haul_job =  HaulJob.new({
      "parent": self,
      "location": self.location,
      "material": material,
      "quantity": lacking_materials[material]
    })

    sub_jobs.push_back(haul_job)
    haul_job.connect("completed", self, "sub_job_completed")

  dirty = false

func sub_job_completed(sub_job):
  .sub_job_completed(sub_job)
  dirty = true

func find_haul_job_by_material(material):
  for job in sub_jobs:
    if job.material == material:
      return job

func can_be_completed():
  ensure_sub_jobs()
  # return true # skip hauling
  return sub_jobs.size() <= 0 and completable
