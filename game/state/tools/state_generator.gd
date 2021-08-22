extends Object
class_name StateGenerator


const ENVIRONMENTS = {
  "core": {
    "gradient": preload("res://game/terrain/res/cores_edge_color_gradient.tres"),
    "curve": preload("res://game/terrain/res/cores_edge_elevation_curve.tres"),
    "height": 35,
    "scale": 1.25,
    "navigable_range": [0.308, 0.312],
  },
  "rim": {
    "gradient": preload("res://game/terrain/res/rim_eternal_color_gradient.tres"),
    "curve": preload("res://game/terrain/res/rim_eternal_elevation_curve.tres"),
    "height": 30,
    "scale": 1.75,
    "navigable_range": [0.498, 0.502],
  },
  "void": {
    "gradient": preload("res://game/terrain/res/voidlands_color_gradient.tres"),
    "curve": preload("res://game/terrain/res/voidlands_elevation_curve.tres"),
    "height": 40,
    "scale": 2.2,
    "navigable_range": [0.498, 0.502],
  },
}


const DEFAULT_TEMPLATE = {
  "environment": "core",
  "terrain": {
    "map_size": 65,
    "elevation_seed": "random",
    "core:forest_seed": "random"
  },
  "pawns": [],
  "items": [],
  "buildings": [],
  "questlines": [
    "core_alliance_heat"
  ],
  "rules": [
    "pawn_trio",
    # "voidblasted_wagon",
    # { "ruins": 3 },
    # { "low_tier_kit": 2 },
    # { "rations": 20 },
    # { "potions": 5 },
    # { "money" 600 },
  ]
}

# Walk a Template and Create a GameState
static func state_from_template(template=DEFAULT_TEMPLATE):
  var state = GameState.new()
  state.map_grid = MapGrid.new()

  # environment selection
  generate_environment(template, state.map_grid)
  generate_map_size(template, state.map_grid)
  generate_terrain_seed(template, state.map_grid)
  # terrain generation
  var terrain_noise = Util.ZeroOneNoise.new(state.map_grid.terrain_seed, ENVIRONMENTS[state.map_grid.environment].scale)

  var forest_seed = generate_forest_seed(template)
  var forest_noise = Util.ZeroOneNoise.new(forest_seed)

  for z in state.map_grid.map_size:
    for x in state.map_grid.map_size:
      var terrain_noise_value = terrain_noise.get_noise_2d(x, z)

      var forest_noise_value = forest_noise.get_noise_2d(x, z)
      generate_forest(state.map_grid, x, z, terrain_noise_value, forest_noise_value)

  # item generation
  # building generation
  # pawn generation

  # quests
  # rules

  return state


static func generate_environment(template, map_grid):
  if template.has("environment"):
    map_grid.environment = template.environment
  else:
    map_grid.environment = ["core", "rim", "void"][randi() % 3]


static func generate_map_size(template, map_grid):
  assert(template.has("terrain") and
    template.terrain.has("map_size") and
    template.terrain.map_size is int,
    "Template does not contain valid terrain.map_size")

  map_grid.map_size = template.terrain.map_size


static func generate_terrain_seed(template, map_grid):
  assert(template.has("terrain") and template.terrain.has("elevation_seed"),
    "Template does not contain terrain.elevation_seed")

  var elevation_seed = template.terrain.elevation_seed

  if elevation_seed == "random":
    map_grid.terrain_seed = Util.random_integer()

  elif elevation_seed is int:
    map_grid.terrain_seed = elevation_seed

  else:
    assert(false, "Unrecognized noise value: %s" % elevation_seed)


static func generate_forest_seed(template):
  assert(template.has("terrain") and template.terrain.has("core:forest_seed"),
    "Template does not contain terrain.core:forest_seed")

  var forest_seed = template.terrain["core:forest_seed"]

  if forest_seed == "random":
    return Util.random_integer()

  elif forest_seed is int:
    return forest_seed

  else:
    assert(false, "Unrecognized noise value: %s" % forest_seed)


static func generate_forest(map_grid, x, z, terrain_value, forest_value):
  if Util.is_between(terrain_value, .31, .685) and forest_value > .65:
    map_grid.forests.push_back({ "x": x, "z": z })
