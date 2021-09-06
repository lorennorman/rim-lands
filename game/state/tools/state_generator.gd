extends Object
class_name StateGenerator


const DEFAULT_TEMPLATE = preload("res://scenarios/standard_start_template.tres")


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
  var terrain_noise = Util.ZeroOneNoise.new(map_grid.terrain_seed, map_grid.environment_settings.scale)
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
    location_index += 5
    if template.use_random_location or template.location == "":
      pawn.location = "%d,%d" % [randi()%location_index, randi()%location_index]
      print(pawn.location)
    else:
      pawn.location = template.location

    # store
    pawns.push_back(pawn)

static func generate_items(_items, _item_templates):
  print("TODO: generate_items()")


static func generate_buildings(_buildings, _building_templates):
  print("TODO: generate_buildings()")
