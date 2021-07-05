extends Node
class_name JobProposal


var game_state#: GameState # circuluar dependency bug
var job: Job
var pawn
var execution_plan: Array
var execution_failure_reason: String

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
      var remaining_quantity = job.quantity
      while remaining_quantity > 0:
        # locate fitting material
        var found_material = game_state.find_closest_available_material_to(job.material, pawn.map_cell)
        if not found_material:
          execution_failure("Not enough material")
          job.uncompletable_until(["item_added", "item_updated"])
          return

        found_material.claimant = pawn # self
        var quantity_to_take = min(found_material.quantity, remaining_quantity)
        remaining_quantity -= quantity_to_take

        add_task({ "move_to": { "location": found_material.map_cell }})
        add_task({ "pick_up": {
          "item": found_material,
          "item_quantity": quantity_to_take,
        }})

      if remaining_quantity == job.quantity: return
      # move_to job
      add_task({ "move_to": { "location": job.map_cell }})
      # dropoff
      var item_to_drop_off = Item.new({ "type": job.material, "quantity": (job.quantity - remaining_quantity) })
      add_task({ "drop_off": { "target": job.parent, "item": item_to_drop_off }})

    Enums.Jobs.BUILD:
      # move to the job site
      if not pawn_in_range(job.map_cell):
        add_task({ "move_to": { "location": job.map_cell }})
      # TODO: check range and bail if still not close enough
      add_task({ "build": {} })


func execution_failure(reason: String):
  execution_failure_reason = reason
  pawn.current_job = null
  job.current_worker = null

  for task in execution_plan:
    if task.has("pick_up"):
      var args = task.pick_up
      game_state.transfer_item_from_to(args.item.type, args.item_quantity, pawn, pawn.map_cell)
      args.item.unclaim()

func execute():
  for task in execution_plan:
    if execution_failure_reason: return
    var task_coroutine = execute_task(task)
    if task_coroutine: yield(task_coroutine, "completed")


func execute_task(task):
  var task_name = task.keys()[0]
  var task_args = task[task_name]
  return self.call(task_name, task_args)


### HELPERS ###
func add_task(task: Dictionary):
  execution_plan.push_back(task)


func pawn_in_range(map_cell: MapCell):
  var pawn_pos: Vector2 = Vector2(pawn.map_cell.x, pawn.map_cell.z)
  var target_pos: Vector2 = Vector2(map_cell.x, map_cell.z)
  var distance = (pawn_pos - target_pos).length()
  return distance < 2


func unassign_job_from_pawn():
  pawn.current_job.current_worker = null
  pawn.current_job = null


### TASKS ###
func move_to(args: Dictionary):
  assert(args.has("location"), "move_to called without a location arg")
  # fetch the A* path
  var move_path = game_state.map_grid.get_move_path(pawn.map_cell, args.location)
  var next_index = 1

  while not pawn_in_range(args.location):
    # Not available yet?
    if pawn.on_cooldown: yield(pawn, "job_cooldown")
    # Pawn removed or job canceled?
    if pawn.removed or job.removed: break
    # Changed jobs before done?
    if pawn.current_job != job: break

    # get the next location
    if next_index >= move_path.size():
      execution_failure("Unnavigable")
      return
    var next_position = move_path[next_index]
    var current_cell = pawn.map_cell
    var next_cell = game_state.map_grid.lookup_cell(next_position)

    # retry if destination is already occupied by a pawn (pawn will freeze)
    if next_cell.pawn:
      # recalculate the move path and go around
      move_path = game_state.map_grid.get_move_path(pawn.map_cell, job.map_cell)
      next_index = 1
      continue

    next_cell.pawn = pawn
    current_cell.pawn = null
    pawn.map_cell = next_cell # triggers the move animation
    next_index += 1

  if not pawn.on_cooldown: pawn.start_job_cooldown(0.01)
  yield(pawn, "job_cooldown")


func build(_args: Dictionary):
  while job.percent_complete < 100:
    # Pawn removed or job canceled
    if pawn.removed or job.removed: break
    # build function :)
    job.percent_complete += pawn.applied_build_speed()
    yield(pawn, "job_cooldown")


func pick_up(args: Dictionary):
  print("Picking up: ", args.item, args.item_quantity)
  game_state.transfer_item_from_to(args.item.type, args.item_quantity, args.item.map_cell, pawn)
  # game_state.pawn_pick_up_material_quantity(pawn, args.item, args.item_quantity)
  args.item.unclaim()


func drop_off(args: Dictionary):
  game_state.transfer_item_from_to(args.item.type, args.item.quantity, pawn, args.target)
  # pawn.remove_item(args.item, args.item.quantity)
  # args.target.add_materials(args.item)
