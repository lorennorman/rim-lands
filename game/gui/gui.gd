extends Spatial

var game_state
var gui_state

func _ready():
  Events.connect("hovered_cell_updated", self, "hovered_cell_updated")
  Events.connect("selected_entity_updated", self, "selected_entity_updated")
  Events.connect("dragged_cell_updated", self, "dragged_cell_updated")
  Events.connect("left_drag_started", self, "left_drag_started")
  Events.connect("left_drag_ended", self, "left_drag_ended")


func hovered_cell_updated(cell):
  var pawn_name = cell.pawn.character_name if cell.pawn else ""
  $Menus/Left/VSplitContainer/VBoxContainer/PawnHoverLabel.text = "Pawn: %s" % pawn_name

  var feature_name = cell.feature.name if cell.feature else ""
  $Menus/Left/VSplitContainer/VBoxContainer/FeatureHoverLabel.text = "Feature: %s" % feature_name

  var color = cell.terrain if cell.terrain else Color(0)
  $Menus/Left/VSplitContainer/VBoxContainer/TerrainHoverLabel/ColorRect.color = color


func selected_entity_updated(entity):
  var focus_text = entity.character_name if entity is Pawn else entity
  $Menus/Left/VSplitContainer/Panel/MarginContainer/TargetFocus.text = "%s" % focus_text


var draggable_building_origin: MapCell
func dragged_cell_updated(cell: MapCell):
  if gui_state.mode == Enums.Mode.BUILD:
    remove_job_markers()
    if not draggable_building_origin: draggable_building_origin = cell

    if draggable_building_origin and cell:
      add_job_markers_between(draggable_building_origin, cell)


func left_drag_ended():
  draggable_building_origin = null
  for building_marker in building_markers:
    var job = building_marker.job
    game_state.add_job(job, job.map_cell.location)
  remove_job_markers()


func left_drag_started():
  draggable_building_origin = gui_state.hovered_cell


var building_markers = []
func remove_job_markers():
  for marker in building_markers:
    marker.queue_free()
  building_markers = []


const MIN_BUILDING_SIZE = 3
const MAX_BUILDING_SIZE = 10
const JobMarker = preload("res://game/gui/3d/job_marker.tscn")
func add_job_markers_between(x1z1, x2z2):
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
    var job = Job.new()
    job.job_type = Enums.Jobs.BUILD
    job.map_cell = cell
    var job_marker = JobMarker.instance()
    job_marker.job = job
    building_markers.push_back(job_marker)
    add_child(job_marker)
