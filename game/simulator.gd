var store: GameStore

func _init(given_store: GameStore):
  assert(given_store, "Simulation initialized without a GameState")
  store = given_store


func _process(_delta):
  for pawn in store.pawns:
    if not pawn.is_busy():
      find_job_for_pawn(pawn)


# pawn/job queue, job acquisition, job completion, reacquisition
func find_job_for_pawn(pawn: Pawn) -> void:
  # TODO: have jobs generate job requests that can be:
  # - claimed with a job proposal, also laying claim to items in proposal
  # - fulfilled
  var shortest_distance: int = 100_000
  var closest_job: Job

  for job in store.getters("all_jobs"):
    if job.is_available(): # this is like a getter query, a scope maybe
      var distance = store.map.get_move_path(pawn.location, job.location).size()
      if distance < shortest_distance:
        shortest_distance = distance
        closest_job = job

  if closest_job: attempt_job(closest_job, pawn)


func attempt_job(job, pawn):
  var job_proposal = JobProposal.new({
    "store": store,
    "pawn": pawn,
    "job": job
  })
  var execution_coroutine = job_proposal.execute()

  if execution_coroutine:
    yield(execution_coroutine, "completed")

  if not job_proposal.execution_failure_reason:
    job.complete()
  else:
    printerr(job_proposal.execution_failure_reason, ": ", job_proposal.pawn.character_name)
