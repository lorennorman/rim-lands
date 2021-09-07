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
  if erase: pawns.erase(pawn)
  StateActivator.deactivate_pawn(pawn, map)
  emit_signal("pawn_removed", pawn)


func add_job(job: Job):
  game_state.jobs.push_back(job)
  StateActivator.activate_job(job, map)
  emit_signal("job_added", job)

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
