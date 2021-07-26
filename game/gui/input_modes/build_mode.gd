extends ModeController
class_name BuildMode

const MIN_BUILDING_SIZE = 3
const MAX_BUILDING_SIZE = 10
const JobMarker = preload("res://game/gui/3d/jobs/job_marker.tscn")

var building_markers = []


func _init(game_state).(game_state): pass


func execute():
  for building_marker in building_markers:
    game_state.add_job(building_marker.job)
  remove_job_markers()


func remove_job_markers():
  for marker in building_markers:
    marker.queue_free()
  building_markers = []


func get_job_markers_between(x1z1, x2z2):
  var x1z1x = x1z1.x
  var x2z2x = x2z2.x
  var min_x = x1z1x - MAX_BUILDING_SIZE
  var max_x = x1z1x + MAX_BUILDING_SIZE
  var small_x = max(min_x, min(x1z1x, x2z2x))
  var large_x = min(max_x, max(x1z1x, x2z2x))
  var x_size = large_x - small_x

  var x1z1z = x1z1.z
  var x2z2z = x2z2.z
  var min_z = x1z1z - MAX_BUILDING_SIZE
  var max_z = x1z1z + MAX_BUILDING_SIZE
  var small_z = max(min_z, min(x1z1z, x2z2z))
  var large_z = min(max_z, max(x1z1z, x2z2z))
  var z_size = large_z - small_z

  if x_size < MIN_BUILDING_SIZE and (x_size <= z_size):
    large_x = x1z1x
    small_x = x1z1x
  if z_size < MIN_BUILDING_SIZE and (z_size < x_size):
    large_z = x1z1z
    small_z = x1z1z

  var square_cells = []
  for x in range(small_x, large_x+1):
    # top wall
    square_cells.push_back(game_state.map_grid.lookup_cell("%d,%d" % [x, small_z]))
    if small_z != large_z:
      # bottom wall
      square_cells.push_back(game_state.map_grid.lookup_cell("%d,%d" % [x, large_z]))

  if small_z != large_z:
    for z in range(small_z+1, large_z):
      # left wall
      square_cells.push_back(game_state.map_grid.lookup_cell("%d,%d" % [small_x, z]))
      if small_x != large_x:
        # right wall
        square_cells.push_back(game_state.map_grid.lookup_cell("%d,%d" % [large_x, z]))

  for cell in square_cells:
    var job = BuildJob.new({
      "location": cell.location,
      "map_cell": cell,
      "building_type": Enums.Buildings.WALL,
      "materials_required": {
        Enums.Items.LUMBER: 5
      }
    })
    var job_marker = JobMarker.instance()
    job_marker.job = job
    building_markers.push_back(job_marker)

  return building_markers
