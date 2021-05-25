var map
var pawns = {}
var jobs = {}

var Pawn = load("res://pawn.gd")
var Job = preload("res://job.gd")

func _init():
  pass

# set up ticker
func start():
  for pawn in pawns.values():
    if not pawn.is_busy():
      find_job_for_pawn(pawn)


# pawn/job queue, job acquisition, job completion, reacquisition
func find_job_for_pawn(pawn):
  for job_queue in jobs.values():
    for job in job_queue:
      if not job.is_claimed():
        assign_job_to_pawn(job, pawn)
        return


func assign_job_to_pawn(job, pawn):
  if pawn.current_job:
    pawn.current_job.current_worker = null
  pawn.current_job = job
  job.current_worker = pawn

  match job.type:
    Enums.Jobs.MOVE:
      if job.location != pawn.location:
        yield(move_pawn_to_job(pawn, job), "completed")
      job.complete()

    Enums.Jobs.BUILD:
      # move to the job site
      if job.location != pawn.location:
        yield(move_pawn_to_job(pawn, job), "completed")
      # until done:
      yield(build_until_done(pawn, job), "completed")
      job.complete()

func move_pawn_to_job(pawn, job):
  # fetch the A* path
  var move_path = map.get_move_path(pawn.location, job.location)
  var next_index = 1

  while next_index < move_path.size():
    # Not available yet?
    if pawn.on_cooldown:
      yield(pawn, "job_cooldown")

    # Changed jobs before done?
    if pawn.current_job != job:
      break

    # get the next location
    var next_position = move_path[next_index]
    next_index += 1
    var current_cell = pawn.map_cell
    var next_cell = map.map_grid.lookup_cell(next_position)

    # attempt to switch locations in the map_grid
    next_cell.pawn = pawn
    current_cell.pawn = null
    # start the tween to the next location
    pawn.map_cell = next_cell

  if pawn.on_cooldown:
    yield(pawn, "job_cooldown")

func build_until_done(pawn, job):
  while job.percent_complete < 100:
    print("buildin")
    job.percent_complete += pawn.applied_build_speed()
    yield(pawn, "job_cooldown")
  print("build done")

## resource management
func make_pawn(type, name, node_key):
  var pawn = Pawn.new()
  pawn.race = type
  pawn.character_name = name
  pawns[node_key] = pawn

  map.set_pawn(node_key, pawn)
  Events.emit_signal("pawn_added", pawn)

  return pawn


func make_job(job_type, job_location, pawn_worker=null):
  var job = Job.new()
  job.type = job_type
  job.location = job_location

  # add to simulator job queue
  if not jobs.has(job_location):
    jobs[job_location] = []
  jobs[job_location].push_back(job)

  Events.emit_signal("job_added", job)

  if pawn_worker:
    assign_job_to_pawn(job, pawn_worker)

  return job
