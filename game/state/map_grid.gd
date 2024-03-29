extends Resource

class_name MapGrid


## Settings from the Terrain Style bundle
export(float, 0.001, 1000) var scale_grid_to_noise = 1.25
export(String) var terrain_style = "Core's Edge" setget set_terrain_style
func set_terrain_style(new_terrain_style):
  terrain_style = new_terrain_style
  var style_settings = terrain_style_lookup[terrain_style]
  terrain_gradient = style_settings.gradient
  terrain_elevation_curve = style_settings.curve
  terrain_height_max = style_settings.height
  scale_grid_to_noise = style_settings.scale
  navigable_range = style_settings.navigable_range

export(float) var terrain_height_max = 35.0
export(Gradient) var terrain_gradient
export(Curve) var terrain_elevation_curve
export(Array) var navigable_range

const terrain_style_lookup = {
  "Core's Edge": {
    "gradient": preload("res://game/terrain/res/cores_edge_color_gradient.tres"),
    "curve": preload("res://game/terrain/res/cores_edge_elevation_curve.tres"),
    "height": 35,
    "scale": 1.25,
    "navigable_range": [0.308, 0.312],
  },
  "The Rim Eternal": {
    "gradient": preload("res://game/terrain/res/rim_eternal_color_gradient.tres"),
    "curve": preload("res://game/terrain/res/rim_eternal_elevation_curve.tres"),
    "height": 30,
    "scale": 1.75,
    "navigable_range": [0.498, 0.502],
  },
  "The Voidlands": {
    "gradient": preload("res://game/terrain/res/voidlands_color_gradient.tres"),
    "curve": preload("res://game/terrain/res/voidlands_elevation_curve.tres"),
    "height": 40,
    "scale": 2.2,
    "navigable_range": [0.498, 0.502],
  },
}


## Per-Map Settings
# Map length/width (maps are always square)
export(int) var map_size = 65
# Random seeds allow random-yet-repeatable maps
export(int) var noise_seed = 2

## Things only used while the map is active/running the game
# Pathfinding Network
var astar: AStar = AStar.new()

# Triply-Indexed Collection of MapCells
var omni_dict: Dictionary

var torn_down := false
var built_up := false


func generate_cells(force = false):
  if built_up and not force: return
  if not terrain_elevation_curve or not terrain_gradient or not navigable_range:
    self.terrain_style = "Core's Edge"

  if astar:
    astar.reserve_space(map_size * map_size)

  omni_dict = {}

  var noise = OpenSimplexNoise.new()
  noise.seed = noise_seed

  for z in map_size:
    for x in map_size:
      var nx = (x * scale_grid_to_noise)
      var nz = (z * scale_grid_to_noise)

      # returns in the range [-1, 1]
      var base_noise = noise.get_noise_2d(nx, nz)

      # Normalize to the range [0, 1]
      var normalized_noise = inverse_lerp(-1, 1, base_noise)

      # height is provided to HTerrainData on the red channel
      var height = height_from_noise(x, z, normalized_noise)
      # height_map.set_pixel(x, z, height_color)
      var color = color_from_noise(x, z, normalized_noise)
      # color_map.set_pixel(x, z, color)

      add_map_grid_cell(x, z, height, color)
  built_up = true
  torn_down = false


func is_navigable(height: float):
  # calculate navigability
  var lowest_navigable_height = navigable_range[0] * terrain_height_max
  var highest_navigable_height = navigable_range[1] * terrain_height_max
  var navigable = (height > lowest_navigable_height) and (height < highest_navigable_height)
  return navigable


func height_from_noise(_x, _z, noise_value):
  # Simple: amplify noise value to a maximum
  # var height = terrain_height_max * noise_value

  # Tool: Use a Curve to draw the contour of your terrain
  var height = terrain_height_max * terrain_elevation_curve.interpolate(noise_value)

  return height


func color_from_noise(_x, _z, noise_value):
  # Tool: Use a gradient to assign colors to the contour curve
  var color = terrain_gradient.interpolate(noise_value)
  return color


func lookup_cell(omni_id):
  if torn_down:
    printerr("lookup_cell called after torn_down at: %s" % omni_id)
    return MapCell.new()

  assert(omni_dict.has(omni_id), "Omni Dict doesn't have ID: '%s'" % omni_id)
  return omni_dict[omni_id]


func set_cell(omni_id, cell):
  omni_dict[omni_id] = cell


func set_pawn(location: String, pawn: Pawn, force=false):
  # cell lookup
  var map_cell: MapCell = lookup_cell(location)

  # bail if exists and we're not forcing
  if map_cell.pawn and not force: return false

  # set or force-evict
  map_cell.pawn = pawn
  pawn.location = location
  pawn.map_cell = map_cell
  return true


func add_map_grid_cell(x, z, height, color):
  # Our new cell
  var map_cell = MapCell.new()
  # The MapGrid we're a part of, so we can lookup neighbors, etc
  map_cell.map_grid = self
  # Apply the terrain
  map_cell.terrain = color

  # Calculate 3D position, mapping us to the terrain, averaging between points
  var average_height
  if x == 0 or z == 0:
    average_height = height
  else:
    var old_height = lookup_cell("%d,%d" % [x-1, z-1]).position.y #height_map.get_pixel(x-1, z-1).r
    average_height = (height + old_height) / 2

  var position = Vector3((x+0.5), average_height, (z+0.5))

  # Store and index position
  map_cell.position = position
  set_cell(position, map_cell)

  # Generate, store, and index location key
  var location_key = "%d,%d" % [x, z]
  map_cell.location = location_key
  set_cell(location_key, map_cell)

  if astar:
    map_cell.disabled = !is_navigable(height)

    # Generate astar id and connect to the pathfinding grid
    var astar_id = astar.get_available_point_id()
    astar.add_point(astar_id, position)
    add_astar_connections(astar_id, x, z)
    if map_cell.disabled:
      astar.set_point_disabled(astar_id, true)

    # Store and index astar id
    map_cell.astar_id = astar_id
    set_cell(astar_id, map_cell)

    map_cell.connect("pathing_updated", self, "pathing_updated")


func pathing_updated(astar_id: int, pathable: bool):
  astar.set_point_disabled(astar_id, !pathable)


func add_astar_connections(astar_id, x, z):
  # Connect up, left, upper-left, and upper-right
  # Note: expects cells to be added LtR
  if z > 0:
    add_astar_connection(astar_id, "%d,%d" % [x, z-1]) # up
  if x > 0:
    add_astar_connection(astar_id, "%d,%d" % [x-1, z]) # left
  if x > 0 and z > 0:
    add_astar_connection(astar_id, "%d,%d" % [x-1, z-1]) # upleft
  if z > 0 and x < map_size - 2:
    add_astar_connection(astar_id, "%d,%d" % [x+1, z-1]) # upright


func add_astar_connection(astar_id, location_key):
  var cell = lookup_cell(location_key)
  # Blow up if we get something we don't expect
  assert(cell, "No connection found between AStar ID: %s and Location %s" % [astar_id, location_key])
  assert(cell.astar_id != astar_id, "Cannot connect AStar node to itself: %s" % astar_id)
  assert(not astar.are_points_connected(astar_id, cell.astar_id), "AStar IDs already connected: %s, %s" % [astar_id, cell.astar_id])

  astar.connect_points(astar_id, cell.astar_id)


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

  assert(false, "Failed to find a good start position. Style: %s, Seed: %s" % [terrain_style, noise_seed])
  return []
