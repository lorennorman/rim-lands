extends ModeController
class_name BuildMode

const MIN_BUILDING_SIZE = 3
const MAX_BUILDING_SIZE = 10
const JobMarker = preload("res://game/gui/3d/jobs/job_marker.tscn")

var build_jobs = []


func consider_from_to(start, end):
  remove_job_markers()

  if start and end:
    for job in get_jobs_between(start, end):
      Events.emit_signal("job_added", job)


func confirm_from_to(_start, _end):
  for job in build_jobs:
    Events.emit_signal("job_removed", job)
    game_state.add_job(job)
  build_jobs = []


func remove_job_markers():
  for job in build_jobs:
    Events.emit_signal("job_removed", job)
  build_jobs = []


func get_jobs_between(start, end):
  for cell in square_of_cells(start, end):
    var job = BuildJob.new({
      "location": cell.location,
      "map_cell": cell,
      "building_type": Enums.Buildings.WALL,
      "materials_required": {
        Enums.Items.LUMBER: 5
      }
    })

    build_jobs.push_back(job)
    # var job_marker = JobMarker.instance()
    # job_marker.job = job
    # building_markers.push_back(job_marker)

  return build_jobs


func square_of_cells(corner_a, corner_b):
  var corner_ax = corner_a.x
  var corner_bx = corner_b.x
  var min_x = corner_ax - MAX_BUILDING_SIZE
  var max_x = corner_ax + MAX_BUILDING_SIZE
  var small_x = max(min_x, min(corner_ax, corner_bx))
  var large_x = min(max_x, max(corner_ax, corner_bx))
  var x_size = large_x - small_x

  var corner_az = corner_a.z
  var corner_bz = corner_b.z
  var min_z = corner_az - MAX_BUILDING_SIZE
  var max_z = corner_az + MAX_BUILDING_SIZE
  var small_z = max(min_z, min(corner_az, corner_bz))
  var large_z = min(max_z, max(corner_az, corner_bz))
  var z_size = large_z - small_z

  if x_size < MIN_BUILDING_SIZE and (x_size <= z_size):
    large_x = corner_ax
    small_x = corner_ax
  if z_size < MIN_BUILDING_SIZE and (z_size < x_size):
    large_z = corner_az
    small_z = corner_az

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

  return square_cells
