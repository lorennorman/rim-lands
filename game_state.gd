extends Resource

class_name GameState

export(Resource) var map_grid setget _set_map_grid
export(Array, Resource) var pawns setget _set_pawns
export(Array, Resource) var jobs

signal map_ready

func _set_map_grid(new_map_grid: MapGrid):
  map_grid = new_map_grid
  emit_signal("map_ready")

func add_pawn(pawn: Pawn, location: String):
  assert(map_grid, "Map must be set before Pawns can be added")
  pawns.push_back(pawn)
  map_grid.set_pawn(location, pawn)
  Events.emit_signal("pawn_added", pawn)

func _set_pawns(all_pawns):
  pawns = []

  if not map_grid:
    yield(self, "map_ready")

  for pawn in all_pawns:
    add_pawn(pawn, pawn.location)


func add_job(job: Job, location: String):
  assert(map_grid, "Map must be set before Jobs can be added")
  jobs.push_back(job)
  job.map_cell = map_grid.lookup_cell(location)
  Events.emit_signal("job_added", job)


func teardown():
  pass
  # destroy all jobs
  # destroy all pawns
  # destroy all map cells
  # destroy map

  # destroy signals will cascade through the scene tree and clean up

# Helpers
func make_pawn(type, name, node_key) -> void:
  var pawn = Pawn.new()
  pawn.race = type
  pawn.character_name = name
  add_pawn(pawn, node_key)


func make_job(job_type, job_location) -> void:
  var job = Job.new()
  job.job_type = job_type
  job.location = job_location
  add_job(job, job_location)
