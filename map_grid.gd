class_name MapGrid

var map_width: int
var map_height: int
var astar: AStar
var omni_dict: Dictionary

func _init(width, height):
  map_width = width
  map_height = height

  astar = AStar.new()
  astar.reserve_space(map_width * map_height)

  omni_dict = {}

func lookup_cell(omni_id):
  if omni_dict.has(omni_id):
    return omni_dict[omni_id]

func set_cell(omni_id, cell):
  omni_dict[omni_id] = cell

func add_map_cell(position, x, z, terrain, disabled=false):
  var map_cell = MapCell.new()

  # Apply the terrain
  map_cell.terrain = terrain
  map_cell.disabled = disabled

  # Store and index position
  map_cell.position = position
  set_cell(position, map_cell)

  # Generate, store, and index location key
  var location_key = "%d,%d" % [x, z]
  map_cell.location = location_key
  set_cell(location_key, map_cell)

  # Generate astar id and connect to the pathfinding grid
  var astar_id = astar.get_available_point_id()
  astar.add_point(astar_id, position)
  add_astar_connections(astar_id, x, z)
  if map_cell.disabled:
    astar.set_point_disabled(astar_id, true)

  # Store and index astar id
  map_cell.astar_id = astar_id
  set_cell(astar_id, map_cell)

func add_astar_connections(astar_id, x, z):
  # Connect up, left, upper-left, and upper-right
  # Note: expects cells to be added LtR
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
  # Blow up if we get something we don't expect
  assert(cell, "No connection found between AStar ID: %s and Location %s" % [astar_id, location_key])
  assert(cell.astar_id != astar_id, "Cannot connect AStar node to itself: %s" % astar_id)
  assert(not astar.are_points_connected(astar_id, cell.astar_id), "AStar IDs already connected: %s, %s" % [astar_id, cell.astar_id])

  astar.connect_points(astar_id, cell.astar_id)

class MapCell:
  extends Resource

  var position: Vector3
  var disabled: bool
  var astar_id: int
  var location: String

  var pawn: Pawn
  var feature
  var terrain
