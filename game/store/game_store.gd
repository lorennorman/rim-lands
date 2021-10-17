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

const ActionProviders = [
  preload("./actions/pawn_actions.gd"),
  preload("./actions/job_actions.gd"),
  preload("./actions/item_actions.gd"),
  preload("./actions/building_actions.gd"),
  preload("./actions/forest_actions.gd"),
]


func _init(new_game_state):
  game_state = new_game_state

  map = Map.new(game_state.map_grid)
  StateActivator.build_map(game_state.map_grid, map)
  StateActivator.stuff_on_map(self, map)

  for Actions in ActionProviders:
    register_actions(Actions.new())


const action_register = {}
func register_actions(action_container):
  for method in action_container.get_method_list():
    if method.name.find("action_") == 0:
      action_register[method.name.substr(7)] = funcref(action_container, method.name)


func getters(property_name):
  print('GETTER: ', property_name)
  return self.get(property_name)


func action(action_name, action_payload):
  print('ACTION: ', action_name, " PAYLOAD: ", action_payload)
  assert(action_register.has(action_name), "Unregistered Action: '%s'" % action_name)
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

var all_jobs setget , get_all_jobs
func get_all_jobs():
  var jobs_and_subjobs = []
  # take all the jobs
  # print("appending", game_state.jobs)
  jobs_and_subjobs.append_array(game_state.jobs)
  for job in game_state.jobs:
    if job.sub_jobs.size() > 0:
      # then take all their subjobs as well
      jobs_and_subjobs.append_array(job.sub_jobs)

  return jobs_and_subjobs

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


### Actions ###

## Pawns ##
## Jobs ##

# TODO: just listen to the jobs directly?
# no, jobs will invoke this as an action like everything else
var _jc = Events.connect("job_completed", self, "complete_job")
func complete_job(job):
  action("complete_job", job)


## Buildings ##
## Forests ##
## Items ##

# getter
func find_closest_available_material_to(material_type, origin_cell: MapCell):
  var closest_item = null
  var distance = 100_000
  for item in getters("items"):
    if item.type != material_type or item.is_claimed() or not item.is_on_map(): continue

    var item_distance = map.get_move_path(origin_cell, item.map_cell).size()
    if item_distance < distance:
      closest_item = item
      distance = item_distance

  print("CLOSEST ITEM: ", closest_item)
  return closest_item



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
    assert(cells[index], "Omni Dict doesn't have a cell at: '%s'" % index)
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
