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


var game_state
var map

func _init(new_game_state):
  game_state = new_game_state

  map = Map.new(game_state.map_grid)
  StateActivator.build_map(game_state.map_grid, map)
  StateActivator.stuff_on_map(self, map)


var pawns setget , get_pawns
func get_pawns():
  return game_state.pawns


var items setget , get_items
func get_items():
  return game_state.items


var buildings setget , get_buildings
func get_buildings():
  return game_state.buildings


var jobs setget , get_jobs
func get_jobs():
  return game_state.jobs


var forests setget , get_forests
func get_forests():
  return game_state.map_grid.forests


### Pawns ###
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


### Jobs ###
func add_job(job: Job):
  game_state.jobs.push_back(job)
  StateActivator.activate_job(job, map)
  emit_signal("job_added", job)


### Buildings ###
func add_building(building):
  game_state.buildings.push_back(building)
  StateActivator.activate_building(building, map)
  emit_signal("building_added", building)


### Items ###
func add_item(item):
  game_state.items.push_back(item)
  StateActivator.activate_item(item, map)
  emit_signal("item_added", item)


## Jobs
func complete_job(job, erase=true):
  match job.job_type:
    Enums.Jobs.BUILD:
      add_building(Building.new({
        type = job.building_type,
        location = job.location
      }))

  if erase: jobs.erase(job)
  job.removed = true
  Events.emit_signal("job_removed", job)


## Forests
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


## Items
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
