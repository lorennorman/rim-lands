class_name MapGrid

var astar
var map_width
var map_height
var position_dict
var location_dict
var astar_dict

func _init(width, height):
  map_width = width
  map_height = height

  astar = AStar.new()
  astar.reserve_space(map_width * map_height)

  position_dict = {}
  location_dict = {}
  astar_dict = {}

func lookup_cell(omni_id):
  if omni_id is String:
    if location_dict.has(omni_id):
      return location_dict[omni_id]

  if omni_id is int:
    if astar_dict.has(omni_id):
      return astar_dict[omni_id]

  if omni_id is Vector3:
    if position_dict.has(omni_id):
      return position_dict[omni_id]

func set_cell(omni_id, cell):
  if omni_id is String:
    if location_dict.has(omni_id):
      print("dupe: ", omni_id)
    location_dict[omni_id] = cell

  if omni_id is int:
    if astar_dict.has(omni_id):
      print("dupe: ", omni_id)
    astar_dict[omni_id] = cell

  if omni_id is Vector3:
    if position_dict.has(omni_id):
      print("dupe: ", omni_id)
    position_dict[omni_id] = cell

func add_map_cell(position, x, z, terrain, disabled=false):
  var map_cell = MapCell.new()

  # Store and index position
  map_cell.position = position
  if lookup_cell(position):
    print("p:", position)
  set_cell(position, map_cell)

  # Generate location key and store it
  var location_key = "%d,%d" % [x, z]
  if lookup_cell(location_key):
    print("l:", location_key)
  map_cell.location = location_key
  set_cell(location_key, map_cell)

  # Apply the terrain
  map_cell.terrain = terrain
  map_cell.disabled = disabled

  # Add to astar and store astar id
  var astar_id = astar.get_available_point_id()
  astar.add_point(astar_id, position)
  map_cell.astar_id = astar_id
  if lookup_cell(astar_id):
    print("a:", astar_id)
  set_cell(astar_id, map_cell)
  add_astar_connections(map_cell, x, z)
  if map_cell.disabled:
    astar.set_point_disabled(astar_id, true)


func add_astar_connections(map_cell, x, z):
  var astar_id = map_cell.astar_id
  # Connect up, left, and the top diagonals
  if z > 0:
    add_astar_connection(astar_id, "%d,%d" % [x, z-1]) # up
  if x > 0:
    add_astar_connection(astar_id, "%d,%d" % [x-1, z]) # left
  if x > 0 and z > 0:
    add_astar_connection(astar_id, "%d,%d" % [x-1, z-1]) # upleft
  if z > 0 and x < map_width-2:
    add_astar_connection(astar_id, "%d,%d" % [x+1, z-1]) # upright

func add_astar_connection(astar_id, location_key):
  var cell = lookup_cell(location_key)
  # Query for up node
  if cell:
    if cell.astar_id == astar_id:
      var othercell = lookup_cell(astar_id)
      print("location: ", cell.location, "<->", othercell.location)
      print("astar: ", cell.astar_id, "<->", othercell.astar_id)
      print("position: ", cell.position, "<->", othercell.position)
    # Apply connection if found
    astar.connect_points(astar_id, cell.astar_id)
  else:
    print("nothing found: ", location_key)

class MapCell:
  var position
  var disabled
  var astar_id
  var location
  var pawn
  var feature
  var terrain
