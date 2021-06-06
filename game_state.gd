extends Resource

class_name GameState

export(Array, Resource) var pawns setget _set_pawns
export(Array, Resource) var jobs setget _set_jobs
export(Resource) var map_grid setget _set_map_grid

var _jc = Events.connect("job_completed", self, "destroy_job")

signal map_ready

func _set_pawns(all_pawns):
  pawns = []

  if not map_grid:
    yield(self, "map_ready")

  for pawn in all_pawns:
    add_pawn(pawn, pawn.location)


func _set_jobs(all_jobs):
  jobs = []

  if not map_grid:
    yield(self, "map_ready")

  for job in all_jobs:
    add_job(job, job.location)


func _set_map_grid(new_map_grid: MapGrid):
  map_grid = new_map_grid
  map_grid.generate_cells()
  emit_signal("map_ready")

func add_pawn(pawn: Pawn, location: String):
  assert(map_grid, "Map must be set before Pawns can be added")
  pawns.push_back(pawn)
  map_grid.set_pawn(location, pawn)
  Events.emit_signal("pawn_added", pawn)


func destroy_pawn(pawn, erase=true):
  if erase: pawns.erase(pawn)
  pawn.removed = true
  map_grid.lookup_cell(pawn.location).pawn = null
  Events.emit_signal("pawn_removed", pawn)


func add_job(job: Job, location: String):
  assert(map_grid, "Map must be set before Jobs can be added")
  jobs.push_back(job)
  job.map_cell = map_grid.lookup_cell(location)
  Events.emit_signal("job_added", job)


func destroy_job(job, erase=true):
  if erase: jobs.erase(job)
  job.removed = true
  Events.emit_signal("job_removed", job)


func add_building(building, location):
  building["map_cell"] = map_grid.lookup_cell(location)
  Events.emit_signal("building_added", building)


func teardown():
  # destroy all jobs
  for job in jobs: destroy_job(job, false)
  jobs.clear()

  # destroy all pawns
  for pawn in pawns: destroy_pawn(pawn, false)
  pawns.clear()

  map_grid.teardown()

  # "destroy_*" signals will cascade through the scene tree and clean up

# Helpers
func make_pawn(type, name, location) -> void:
  var pawn = Pawn.new()
  pawn.race = type
  pawn.character_name = name
  add_pawn(pawn, location)


func make_job(job_type, job_location, job_params) -> void:
  var job = Job.new()
  job.job_type = job_type
  job.location = job_location
  if job_params: job.params = job_params
  add_job(job, job_location)

func make_building(building_type, building_location) -> void:
  var building = Building.new()
  building.type = building_type
  building.location = building_location

  add_building(building, building_location)
