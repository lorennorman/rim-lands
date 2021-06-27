extends Node
class_name JobProposal

var game_state: GameState
var job: Job
var pawn: Pawn
var execution_plan: Array


func _init(mass_assignments: Dictionary = {}):
  Util.mass_assign(self, mass_assignments)
  assert(game_state, "JobProposal initialized without a GameState")
  assert(job, "JobProposal initialized without a Job")
  assert(pawn, "JobProposal initialized without a Pawn")

  pawn.current_job = job
  job.current_worker = pawn

  generate_execution_plan()


func generate_execution_plan():
  # build the execution plan
  match job.job_type:
    Enums.Jobs.HAUL:
      execution_plan = [
        { "task": "move_to_material" },
        { "task": "pick_up_material" },
        { "task": "pick_up_job" },
        { "task": "drop_off_material" },
      ]
    Enums.Jobs.BUILD:
      # move to the job site
      if not pawn_in_range_of_job():
        # var movement_coroutine = move_pawn_to_job()
        # if movement_coroutine: yield(movement_coroutine, "completed")
        execution_plan.push_back({ "task": "move_to", "args": { "location": job.location }})
      # still not in range? can't path, drop this job
      # if not pawn_in_range_of_job():
      #   unassign_job_from_pawn()
      #   return
      execution_plan.push_back({ "task": "build" })
      # yield(build_until_done(), "completed")
      # game_state.make_building(job.building_type, job.location)
      # job.complete()


func execute():
  for task in execution_plan:
    var task_coroutine = execute_task(task)
    if task_coroutine: yield(task_coroutine, "completed")

func execute_task(task):
  var args = task.args if task.has("args") else {}
  return self.call(task.task, args)
  #
  # match job.job_type:
  #   Enums.Jobs.MOVE:
  #     if job.location != pawn.location:
  #       yield(move_pawn_to_job(), "completed")
  #     job.complete()
  #
  #   Enums.Jobs.BUILD:
  #     # move to the job site
  #     if not pawn_in_range_of_job():
  #       var movement_coroutine = move_pawn_to_job()
  #       if movement_coroutine: yield(movement_coroutine, "completed")
  #     # still not in range? can't path, drop this job
  #     if not pawn_in_range_of_job():
  #       unassign_job_from_pawn()
  #       return
  #     yield(build_until_done(), "completed")
  #     game_state.make_building(job.building_type, job.location)
  #     job.complete()
  #

func pawn_in_range_of_job():
  var pawn_pos: Vector2 = Vector2(pawn.map_cell.x, pawn.map_cell.z)
  var job_pos: Vector2 = Vector2(job.map_cell.x, job.map_cell.z)
  var distance = (pawn_pos - job_pos).length()
  return distance < 2


func move_to(args):
  assert(args.location, "move_to called without a location arg")
  # fetch the A* path
  var move_path = game_state.map_grid.get_move_path(pawn.location, args.location)
  var next_index = 1
  # can't get to job
  if move_path.size() == 0: return
  while not pawn_in_range_of_job():
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


func build(_args={}):
  while job.percent_complete < 100:
    # Pawn removed or job canceled
    if pawn.removed or job.removed: break
    # build function :)
    job.percent_complete += pawn.applied_build_speed()
    yield(pawn, "job_cooldown")


func unassign_job_from_pawn():
  pawn.current_job.current_worker = null
  pawn.current_job = null
