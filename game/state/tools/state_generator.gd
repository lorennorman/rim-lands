extends Object
class_name StateGenerator


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
    # { "startup_text": "What was that? The wagon is destroyed and you're free..." }
  ]
}

# Walk a Template and Create a GameState
static func state_from_template(template=DEFAULT_TEMPLATE):
  var state = GameState.new()
  state.map_grid = MapGrid.new()

  generate_map(state.map_grid, template.map_template)
  generate_pawns(state.pawns, template.pawn_templates)
  generate_items(state.items, template.item_templates)
  generate_buildings(state.buildings, template.building_templates)

  # quests
  # rules
  for rule in template.rules:
    if rule is String:
      match rule:
        "pawn_trio":
          var pawns = Factory.Pawns.default_pawns()
          state.pawns.append_array(pawns)

          # positioning...
          # var cells = state.map_grid.find_good_starting_positions(3)
          # for index in pawns.size():
          #   var pawn = pawns[index]
          #   var map_cell = cells[index]
          #   pawn.map_cell = map_cell
        _: printerr("Unrecognized rule: %s" % rule)
    else:
      printerr("Unrecognized rule type: %s" % rule)

  return state


static func generate_map(map_grid, map_template):
  # environment selection
  generate_environment(map_template, map_grid)
  generate_map_size(map_template, map_grid)
  generate_terrain_seed(map_template, map_grid)

  if map_grid.environment != "core": return

  # forest generation
  var terrain_noise = Util.ZeroOneNoise.new(map_grid.terrain_seed, ENVIRONMENTS[map_grid.environment].scale)
  var forest_seed = generate_forest_seed(map_template)
  var forest_noise = Util.ZeroOneNoise.new(forest_seed)

  for z in map_grid.map_size:
    for x in map_grid.map_size:
      var terrain_noise_value = terrain_noise.get_noise_2d(x, z)

      var forest_noise_value = forest_noise.get_noise_2d(x, z)
      if Util.is_between(terrain_noise_value, .31, .685) and forest_noise_value > .65:
        map_grid.forests.push_back({ "x": x, "z": z })


static func generate_environment(map_template, map_grid):
  if map_template.environment:
    map_grid.environment = map_template.environment
  else:
    map_grid.environment = ["core", "rim", "void"][randi() % 3]


static func generate_map_size(map_template, map_grid):
  map_grid.map_size = map_template.map_size


static func generate_terrain_seed(map_template, map_grid):
  if map_template.use_random_terrain_seed or not map_template.terrain_seed:
    map_grid.terrain_seed = Util.random_integer()
    # flatten randoms
    map_template.use_random_terrain_seed = false
    map_template.terrain_seed = map_grid.terrain_seed
  else:
    map_grid.terrain_seed = map_template.terrain_seed


static func generate_forest_seed(map_template):
  if map_template.use_random_forest_seed or not map_template.forest_seed:
    var forest_seed = Util.random_integer()
    # flatten randoms
    map_template.use_random_forest_seed = false
    map_template.forest_seed = forest_seed
    return forest_seed
  else:
    return map_template.forest_seed


static func generate_pawns(pawns, pawn_templates):
  var location_index = 0
  for template in pawn_templates:
    # create
    var pawn = Pawn.new()

    # race
    if template.use_random_race or template.race == "":
      pawn.race = ["Hum", "Dorv", "Alv"][randi() % 3]
    else:
      pawn.race = template.race

    # name
    if template.use_random_name or template.name == "":
      match pawn.race:
        "Hum": pawn.character_name = ["Conraz", "Mathum", "Walduf"][randi() % 3]
        "Dorv": pawn.character_name = ["Brindolf", "Grizwund", "Utzvein"][randi() % 3]
        "Alv": pawn.character_name = ["s'Randra", "z'Rulrah", "Elin'tor"][randi() % 3]
        _: printerr("Unknown race to generate name for: %s" % pawn.race)
    else:
      pawn.character_name = template.name

    # location
    if template.use_random_location or template.location == "":
      pawn.location = "%d,%d" % [location_index, location_index]
    else:
      pawn.location = template.location
    location_index += 1

    # store
    pawns.push_back(pawn)

static func generate_items(_items, _item_templates):
  print("TODO: generate_items()")


static func generate_buildings(_buildings, _building_templates):
  print("TODO: generate_buildings()")
