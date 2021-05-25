class_name MapGrid

var astar
var master_dict

func _init(width, height):
  astar = AStar.new()
  astar.reserve_space(width * height)

  master_dict = {}

func lookup_cell(omni_id):
  if master_dict.has(omni_id):
    return master_dict[omni_id]


func add_map_cell(position, terrain, disabled=false):
  var map_cell = MapCell.new()

  # Store and index position
  map_cell.position = position
  master_dict[position] = map_cell

  # Generate location key and store it
  var location_key = "%d,%d" % [position.x, position.z]
  map_cell.location = location_key
  master_dict[location_key] = map_cell

  # Apply the terrain
  map_cell.terrain = terrain
  map_cell.disabled = disabled

  # Add to astar and store astar id
  var astar_id = astar.get_available_point_id()
  astar.add_point(astar_id, position)
  map_cell.astar_id = astar_id
  master_dict[astar_id] = map_cell
  add_astar_connections(map_cell)
  if map_cell.disabled:
    astar.set_point_disabled(astar_id, true)


func add_astar_connections(map_cell):
  var astar_id = map_cell.astar_id
  var x = map_cell.position.x
  var z = map_cell.position.z
  # Connect up, left, and the top diagonals
  add_astar_connection(astar_id, "%d,%d" % [x, z-1]) # up
  add_astar_connection(astar_id, "%d,%d" % [x-1, z]) # left
  add_astar_connection(astar_id, "%d,%d" % [x-1, z-1]) # upleft
  add_astar_connection(astar_id, "%d,%d" % [x+1, z-1]) # upright

func add_astar_connection(astar_id, location_key):
  var cell = lookup_cell(location_key)
  # Query for up node
  if cell:
    # Apply connection if found
    astar.connect_points(astar_id, cell.astar_id)


class MapCell:
  var position
  var disabled
  var astar_id
  var location
  var pawn
  var feature
  var terrain
