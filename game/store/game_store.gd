extends Reference
class_name GameStore


signal game_state_teardown

signal forest_collection_added(forests)
signal forest_added(forest)
signal forest_removed(forest)

signal pawn_collection_added(pawns)
signal pawn_added(pawn)
signal pawn_updated(pawn)
signal pawn_checked(pawn)
signal pawn_removed(pawn)

signal job_collection_added(jobs)
signal job_added(job)
signal job_updated(job)
signal job_checked(job)
signal job_removed(job)

signal building_collection_added(buildings)
signal building_added(building)
signal building_checked(building)
signal building_removed(building)

signal item_collection_added(items)
signal item_added(item)
signal item_updated(item)
signal item_checked(item)
signal item_removed(item)

# Reactive Store Signals
signal getter(getter_name)
signal mutation(resource_name)

var game_state
var map

func _init(new_game_state):
  game_state = new_game_state

  map = Map.new(game_state.map_grid)
  StateActivator.build_map(game_state.map_grid, map)
  StateActivator.stuff_on_map(self, map)

  register_actions(JobActions.new())


const action_register = {}
func register_actions(action_container):
  for method in action_container.get_method_list():
    if method.name.find("action_") == 0:
      action_register[method.name.substr(7)] = funcref(action_container, method.name)

  print("Registered Actions: ", action_register)


func action(action_name, action_payload):
  print("Action: ", action_name)
  print("Payload: ", action_payload)

  var action_funcref = action_register[action_name]
  action_funcref.call_func(self, action_payload)


var pawns setget , get_pawns
func get_pawns():
  emit_signal("getter", "pawns")
  return game_state.pawns


var items setget , get_items
func get_items():
  emit_signal("getter", "items")
  return game_state.items


var buildings setget , get_buildings
func get_buildings():
  emit_signal("getter", "buildings")
  return game_state.buildings


var jobs setget , get_jobs
func get_jobs():
  emit_signal("getter", "jobs")
  return game_state.jobs


var forests setget , get_forests
func get_forests():
  emit_signal("getter", "forests")
  return game_state.map_grid.forests


# Reactive Stuff: Getter Observation
var getter_invocations = []
func collect_getter_invocations():
  connect("getter", self, "add_getter_invocation")


func add_getter_invocation(getter_name):
  print("adding invocation for: ", getter_name)
  getter_invocations.push_back(getter_name)


func retrieve_getter_invocations():
  disconnect("getter", self, "add_getter_invocation")
  var to_return = getter_invocations.duplicate()
  getter_invocations.clear()
  return to_return


func register_reactive_function(target, func_name):
  # listen_to_getters
  collect_getter_invocations()
  target.call(func_name, self)
  # retrieve accessed getters
  var invocations = retrieve_getter_invocations()
  # register action listeners for each of them
  print(invocations)
  for getter_name in invocations:
    connect_to_mutation(getter_name, target, func_name)


var mutation_listeners = {}
var m = connect("mutation", self, "route_mutation")
func route_mutation(resource_type):
  if !mutation_listeners.has(resource_type): return

  for listener in mutation_listeners[resource_type]:
    listener[0].call(listener[1], self)


func connect_to_mutation(resource_type, update_target, update_func):
  if !mutation_listeners.has(resource_type):
    mutation_listeners[resource_type] = []

  mutation_listeners[resource_type].push_back([update_target, update_func])


func getters(property_name):
  return self.get(property_name)


### Actions ###

## Pawns ##
func add_pawn(new_pawn: Pawn):
  # pass
  # gather resources
  # check premises
  # mutate state
  game_state.pawns.push_back(new_pawn)
  StateActivator.activate_pawn(new_pawn, map)
  # signal broadly
  emit_signal("pawn_added", new_pawn)


func destroy_pawn(pawn, erase=true):
  if erase: game_state.pawns.erase(pawn)
  StateActivator.deactivate_pawn(pawn, map)
  emit_signal("pawn_removed", pawn)


## Jobs ##
func add_job(job: Job):
  game_state.jobs.push_back(job)
  StateActivator.activate_job(job, map)
  emit_signal("job_added", job)
  emit_signal("mutation", "jobs")

# TODO: just listen to the jobs directly?
# no, jobs will invoke this as an action like everything else
var _jc = Events.connect("job_completed", self, "complete_job")
func complete_job(job):
  # TODO: move this into the job
  match job.job_type:
    Enums.Jobs.BUILD:
      add_building(Building.new({
        type = job.building_type,
        location = job.location
      }))

  destroy_job(job)


func destroy_job(job):
  self.jobs.erase(job)
  StateActivator.deactivate_job(job)
  emit_signal("job_removed", job)
  emit_signal("mutation", "jobs")

## Buildings ##
func add_building(building):
  game_state.buildings.push_back(building)
  StateActivator.activate_building(building, map)
  emit_signal("building_added", building)


## Forests ##
func buildup_forest(forest):
  StateActivator.activate_forest(forest, map)


func destroy_forest(forest_dict):
  var found_forest

  for forest in self.forests:
    if forest.x == forest_dict.x and forest.z == forest_dict.z:
      found_forest = forest
      break

  if found_forest:
    self.forests.erase(found_forest)
    emit_signal("forest_removed", found_forest)

  else:
    printerr("Didn't find a matching forest for %s" % forest_dict)


## Items ##
func add_item(item):
  game_state.items.push_back(item)
  StateActivator.activate_item(item, map)
  emit_signal("item_added", item)


func destroy_item(item):
  items.erase(item)
  StateActivator.deactivate_item(item)
  Events.emit_signal("item_removed", item)


func find_closest_available_material_to(material_type, origin_cell: MapCell):
  var closest_item = null
  var distance = 100_000
  for item in items:
    if item.type != material_type or item.is_claimed() or not item.is_on_map(): continue

    var item_distance = map.get_move_path(origin_cell, item.map_cell).size()
    if item_distance < distance:
      closest_item = item
      distance = item_distance

  return closest_item


func transfer_item_from_to(item_type: int, item_quantity: int, from: Resource, to: Resource):
  # check that "from" has enough of this item
  var from_item = from.get_item(item_type)
  assert(from_item, "Attempted to transfer an item the source doesn't have: %s" % item_type)
  assert(from_item.quantity >= item_quantity, "Attempted to transfer more of an item than the source has: %s < %s" % [from_item.quantity, item_quantity])
  from_item.quantity -= item_quantity
  if from_item.quantity <= 0: destroy_item(from_item)

  # check if "to" already has some of this item
  var to_item = to.get_item(item_type)
  if to_item:
    to_item.quantity += item_quantity
  else:
    # do the new
    to_item = Item.new({
      "type": item_type,
      "quantity": item_quantity,
      "owner": to
    })
    add_item(to_item)



class Map:
  var astar := AStar.new()
  var cells := {}
  var size
  var environment

  func _init(map_grid):
    size = map_grid.map_size
    environment = map_grid.environment_settings

  func set_cell(index, cell):
    assert(not cells.has(index), "Cell already present at: %s" % index)
    cells[index] = cell


  func lookup_cell(index):
    assert(cells.has(index), "Omni Dict doesn't have ID: '%s'" % index)
    return cells[index]


  func get_move_path(from_key, to_key):
    var from_id = lookup_cell(from_key).astar_id if from_key is String else from_key.astar_id
    var to_id = lookup_cell(to_key).astar_id if to_key is String else to_key.astar_id
    return astar.get_point_path(from_id, to_id)


  func find_good_starting_positions(how_many) -> Array:
    # assert(astar, "AStar operation called: find_good_starting_positions(%s)" % [how_many])

    # var third = map_size/3
    var third = float(cells.values().size())/9
    # try each third of the map
    for x_third in [third, third*2]:
      for z_third in [third, third*2]:
        # ask for closest astar
        var close_astar_id = astar.get_closest_point(Vector3(x_third, 0, z_third))
        if close_astar_id < 0: continue
        var closest_cell = lookup_cell(close_astar_id)
        if closest_cell:
          # ensure 2 more are connected
          var neighbors = astar.get_point_connections(close_astar_id)
          if neighbors.size() >= how_many:
            var final_positions = [closest_cell]
            for index in how_many:
              final_positions.push_back(lookup_cell(neighbors[index]))

            return final_positions

    assert(false, "Failed to find a good start position.") # Style: %s, Seed: %s" % [terrain_style, noise_seed])
    return []
