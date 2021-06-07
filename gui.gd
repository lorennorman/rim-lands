extends Spatial

var gui_state

func _ready():
  var _hcu = Events.connect("hovered_cell_updated", self, "hovered_cell_updated")
  var _scu = Events.connect("selected_cell_updated", self, "selected_cell_updated")
  var _seu = Events.connect("selected_entity_updated", self, "selected_entity_updated")
  var _dcu = Events.connect("dragged_cell_updated", self, "dragged_cell_updated")
  var _lds = Events.connect("left_drag_started", self, "left_drag_started")
  var _lde = Events.connect("left_drag_ended", self, "left_drag_ended")

func hovered_cell_updated(cell):
  var pawn_name = cell.pawn.character_name if cell.pawn else ""
  $Menus/Left/VSplitContainer/VBoxContainer/PawnHoverLabel.text = "Pawn: %s" % pawn_name

  var feature_name = cell.feature.name if cell.feature else ""
  $Menus/Left/VSplitContainer/VBoxContainer/FeatureHoverLabel.text = "Feature: %s" % feature_name

  var color = cell.terrain if cell.terrain else Color(0)
  $Menus/Left/VSplitContainer/VBoxContainer/TerrainHoverLabel/ColorRect.color = color

  $HoverIndicator.translation = cell.position


func selected_entity_updated(entity):
  var focus_text = entity.character_name if entity is Pawn else entity
  $Menus/Left/VSplitContainer/Panel/MarginContainer/TargetFocus.text = "%s" % focus_text


func selected_cell_updated(cell):
  $SelectIndicator.translation = cell.position


var draggable_building_origin: MapCell
func dragged_cell_updated(cell: MapCell):
  if gui_state.mode == Enums.Jobs.BUILD:
    remove_job_markers()
    if not draggable_building_origin: draggable_building_origin = cell

    if draggable_building_origin and cell:
      add_job_markers_between(draggable_building_origin, cell)


func left_drag_ended():
  draggable_building_origin = null
  remove_job_markers()


func left_drag_started():
  draggable_building_origin = gui_state.hovered_cell


var building_markers = []
func remove_job_markers():
  for marker in building_markers:
    remove_child(marker)
    marker.queue_free()
  building_markers = []

const JobMarker = preload("res://job_marker.tscn")
func add_job_markers_between(x1y1, x2y2):
  for cell in [x1y1, x2y2]:
    var job = Job.new()
    job.job_type = Enums.Jobs.BUILD
    job.map_cell = cell
    var job_marker = JobMarker.instance()
    job_marker.job = job
    building_markers.push_back(job_marker)
    add_child(job_marker)
