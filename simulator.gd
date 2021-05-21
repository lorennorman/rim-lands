var map
var pawns = {}
var jobs = {}

var Pawn = load("res://pawn.gd")
var Job = preload("res://job.gd")

func _init():
  pass

func start():
  for pawn in pawns.values():
    if not pawn.is_busy():
      find_job_for_pawn(pawn)

func find_job_for_pawn(pawn):
  for job_queue in jobs.values():
    for job in job_queue:
      if not job.is_claimed():
        assign_job_to_pawn(job, pawn)
        return

func assign_job_to_pawn(job, pawn):
  pawn.current_job = job
  job.current_worker = pawn

func make_pawn(type, name, node_key):
  var pawn = Pawn.new()
  pawn.race = type
  pawn.character_name = name
  pawns[node_key] = pawn

  map.set_pawn(node_key, pawn)
  Events.emit_signal("pawn_added", pawn)

  return pawn

signal job_added(job)
signal job_removed(job)

func make_job(job_name, job_location):
  var job = Job.new()
  job.name = job_name
  job.location = job_location

  # add to simulator job queue
  if not jobs.has(job_location):
    jobs[job_location] = []
  jobs[job_location].push_back(job)

  Events.emit_signal("job_added", job)

  return job
