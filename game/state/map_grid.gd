extends Resource
class_name MapGrid


const ENVIRONMENTS = {
  "core": {
    "name": "Core's Edge",
    "gradient": preload("res://game/terrain/res/cores_edge_color_gradient.tres"),
    "curve": preload("res://game/terrain/res/cores_edge_elevation_curve.tres"),
    "height": 35,
    "scale": 1.25,
    "navigable_range": [0.308, 0.312],
  },
  "rim": {
    "name": "The Rim Eternal",
    "gradient": preload("res://game/terrain/res/rim_eternal_color_gradient.tres"),
    "curve": preload("res://game/terrain/res/rim_eternal_elevation_curve.tres"),
    "height": 30,
    "scale": 1.75,
    "navigable_range": [0.498, 0.502],
  },
  "void": {
    "name": "The Voidlands",
    "gradient": preload("res://game/terrain/res/voidlands_color_gradient.tres"),
    "curve": preload("res://game/terrain/res/voidlands_elevation_curve.tres"),
    "height": 40,
    "scale": 2.2,
    "navigable_range": [0.498, 0.502],
  },
}


## Map Settings
# Terrain Environment
export(String) var environment = "core"
# Map length/width (maps are always square)
export(int) var map_size = 65
# Random seeds allow random-yet-repeatable maps
export(int) var terrain_seed = 2
# export(int) var forest_noise_seed = -2
export(Array) var forests = []

## Things only used while the map is active/running the game
# Pathfinding Network
var astar: AStar = AStar.new()
# Triply-Indexed Collection of MapCells
var omni_dict: Dictionary

var torn_down := false
var built_up := false
# Environment lookup helper
var environment_settings setget , get_environment_settings
func get_environment_settings(): return ENVIRONMENTS[self.environment]


func set_cell(omni_id, cell):
  omni_dict[omni_id] = cell


func lookup_cell(omni_id):
  if torn_down:
    printerr("lookup_cell called after torn_down at: %s" % omni_id)
    return MapCell.new()

  assert(omni_dict.has(omni_id), "Omni Dict doesn't have ID: '%s'" % omni_id)
  return omni_dict[omni_id]


func pathing_updated(astar_id: int, pathable: bool):
  astar.set_point_disabled(astar_id, !pathable)


func get_move_path(from_key, to_key):
  assert(astar, "AStar operation called: get_move_path(%s, %s)" % [from_key, to_key])
  var from_id = lookup_cell(from_key).astar_id if from_key is String else from_key.astar_id
  var to_id = lookup_cell(to_key).astar_id if to_key is String else to_key.astar_id
  return astar.get_point_path(from_id, to_id)


func teardown():
  torn_down = true
  built_up = false
  omni_dict.clear() # clear the map cells
  if astar: astar.clear() # clear the astar network


func find_good_starting_positions(how_many) -> Array:
  # assert(astar, "AStar operation called: find_good_starting_positions(%s)" % [how_many])

  var third = map_size/3
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
