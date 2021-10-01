extends Object
class_name ModeController

var store

func _init(new_store=null):
  store = new_store


# by default let right click bail out to the basic selection mode
func cancel(_cell):
  store.mode = { "mode": Enums.Mode.SELECT }


func confirm(_cell):
  printerr("%s Didn't implement confirm" % self)


func consider_from_to(_start, _end):
  printerr("%s Didn't implement consider_from_to" % self)


func confirm_from_to(_start, _end):
  printerr("%s Didn't implement confirm_from_to" % self)


# Util Functions
func generalize_points_and_bounds(corner_a, corner_b, min_size=1, max_size=8):
  var corner_ax = corner_a.x
  var corner_bx = corner_b.x
  var min_x = corner_ax - max_size
  var max_x = corner_ax + max_size
  var small_x = max(min_x, min(corner_ax, corner_bx))
  var large_x = min(max_x, max(corner_ax, corner_bx))
  var x_size = large_x - small_x

  var corner_az = corner_a.z
  var corner_bz = corner_b.z
  var min_z = corner_az - max_size
  var max_z = corner_az + max_size
  var small_z = max(min_z, min(corner_az, corner_bz))
  var large_z = min(max_z, max(corner_az, corner_bz))
  var z_size = large_z - small_z

  if x_size < min_size and (x_size <= z_size):
    large_x = corner_ax
    small_x = corner_ax
  if z_size < min_size and (z_size < x_size):
    large_z = corner_az
    small_z = corner_az

  return {
    "left": small_x,
    "right": large_x,
    "top": small_z,
    "bottom": large_z
  }


func square_of_cells(corner_a, corner_b, min_size=1, max_size=8):
  var bounds = generalize_points_and_bounds(corner_a, corner_b, min_size, max_size)
  var square_cells = []
  for x in range(bounds.left, bounds.right+1):
    # top wall
    square_cells.push_back(store.map.lookup_cell("%d,%d" % [x, bounds.top]))
    if bounds.top != bounds.bottom:
      # bottom wall
      square_cells.push_back(store.map.lookup_cell("%d,%d" % [x, bounds.bottom]))

  if bounds.top != bounds.bottom:
    for z in range(bounds.top+1, bounds.bottom):
      # left wall
      square_cells.push_back(store.map.lookup_cell("%d,%d" % [bounds.left, z]))
      if bounds.left != bounds.right:
        # right wall
        square_cells.push_back(store.map.lookup_cell("%d,%d" % [bounds.right, z]))

  return square_cells


func filled_square_of_cells(corner_a, corner_b, min_size=1, max_size=8):
  var bounds = generalize_points_and_bounds(corner_a, corner_b, min_size, max_size)
  var square_cells = []

  for x in range(bounds.left, bounds.right):
    for z in range(bounds.top, bounds.bottom):
      square_cells.push_back(store.map.lookup_cell("%d,%d" % [x, z]))

  return square_cells

func one_out_of(denominator: int, collection):
  var random_filtered = []
  for cell in collection:
    if randi() % denominator == 0:
      random_filtered.push_back(cell)

  return random_filtered
