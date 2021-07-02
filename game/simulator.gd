var game_state: GameState

func _init(given_game_state: GameState):
  assert(given_game_state, "Simulation initialized without a GameState")
  game_state = given_game_state


func _process(_delta):
  for pawn in game_state.pawns:
    if not pawn.is_busy():
      find_job_for_pawn(pawn)

# pawn/job queue, job acquisition, job completion, reacquisition
func find_job_for_pawn(pawn: Pawn) -> void:
  # TODO: have jobs generate job requests that can be:
  # - claimed with a job proposal, also laying claim to items in proposal
  # - fulfilled
  var shortest_distance: int = 100_000
  var closest_job: Job

  for job in game_state.jobs:
    if job.can_be_completed() and not job.is_claimed():
      var distance = game_state.map_grid.get_move_path(pawn.location, job.location).size()
      if distance < shortest_distance:
        shortest_distance = distance
        closest_job = job

  if closest_job: propose_job_by_pawn(closest_job, pawn)

func propose_job_by_pawn(job, pawn):
  var job_proposal = JobProposal.new({ "game_state": game_state, "pawn": pawn, "job": job })
  var execution_coroutine = job_proposal.execute()
  if execution_coroutine: yield(execution_coroutine, "completed")
  if not job_proposal.execution_failure_reason:
    job.complete()
  else: printerr(job_proposal.execution_failure_reason, ": ", job_proposal.pawn.character_name)
