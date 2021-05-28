extends Resource

class_name GameState

export(Array, Resource) var pawns
export(Array, Resource) var jobs
export(Resource) var map

## resource management
func make_pawn(type, name, node_key) -> void:
  assert(map, "Map must be set before Pawns can be added")
  var pawn = Pawn.new()
  pawn.race = type
  pawn.character_name = name
  pawns.push_back(pawn)

  map.set_pawn(node_key, pawn)
  Events.emit_signal("pawn_added", pawn)


func make_job(job_type, job_location) -> void:
  assert(map, "Map must be set before Jobs can be added")
  var job = Job.new()
  job.type = job_type
  job.location = job_location
  job.map_cell = map.map_grid.lookup_cell(job_location)

  # add to simulator job queue
  jobs.push_back(job)

  Events.emit_signal("job_added", job)
