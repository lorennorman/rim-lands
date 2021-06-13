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
  var shortest_distance: int = 100_000
  var closest_job: Job

  for job in game_state.jobs:
    if not job.is_claimed():
      var distance = game_state.map_grid.get_move_path(pawn.location, job.location).size()
      if distance < shortest_distance:
        shortest_distance = distance
        closest_job = job

  if closest_job: assign_job_to_pawn(closest_job, pawn)


func assign_job_to_pawn(job: Job, pawn: Pawn) -> void:
  if pawn.current_job:
    pawn.current_job.current_worker = null
  pawn.current_job = job
  job.current_worker = pawn

  match job.job_type:
    Enums.Jobs.MOVE:
      if job.location != pawn.location:
        yield(move_pawn_to_job(pawn, job), "completed")
      job.complete()

    Enums.Jobs.BUILD:
      # move to the job site
      if not pawn_in_range_of_job(pawn, job):
        yield(move_pawn_to_job(pawn, job), "completed")
      # until done:
      yield(build_until_done(pawn, job), "completed")
      game_state.make_building(job.building_type, job.location)
      job.complete()

func pawn_in_range_of_job(pawn: Pawn, job: Job):
  var pawn_pos: Vector2 = Vector2(pawn.map_cell.x, pawn.map_cell.z)
  var job_pos: Vector2 = Vector2(job.map_cell.x, job.map_cell.z)
  var distance = (pawn_pos - job_pos).length()
  return distance < 2

func move_pawn_to_job(pawn: Pawn, job: Job):
  # fetch the A* path
  var move_path = game_state.map_grid.get_move_path(pawn.location, job.location)
  var next_index = 1
  # while next_index < move_path.size():
  while not pawn_in_range_of_job(pawn, job):
    # Not available yet?
    if pawn.on_cooldown: yield(pawn, "job_cooldown")
    # Pawn removed or job canceled?
    if pawn.removed or job.removed: break
    # Changed jobs before done?
    if pawn.current_job != job: break

    # get the next location
    var next_position = move_path[next_index]
    var current_cell = pawn.map_cell
    var next_cell = game_state.map_grid.lookup_cell(next_position)

    # retry if destination is already occupied by a pawn (pawn will freeze)
    if next_cell.pawn:
      # recalculate the move path and go around
      move_path = game_state.map_grid.get_move_path(pawn.location, job.location)
      next_index = 1
      continue

    next_cell.pawn = pawn
    current_cell.pawn = null
    pawn.map_cell = next_cell # triggers the move animation
    next_index += 1

  if not pawn.on_cooldown: pawn.start_job_cooldown(0.01)
  yield(pawn, "job_cooldown")


func build_until_done(pawn: Pawn, job: Job):
  while job.percent_complete < 100:
    # Pawn removed or job canceled
    if pawn.removed or job.removed: break
    # build function :)
    job.percent_complete += pawn.applied_build_speed()
    yield(pawn, "job_cooldown")
