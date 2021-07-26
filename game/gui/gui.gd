extends Spatial

const DraggableCells = preload("res://game/gui/draggable_cells.gd")

var game_state
var gui_state
onready var enable_draggable_cells = DraggableCells.new()

func _ready():
  Events.connect("mode_updated", self, "mode_updated")
  mode_controller = SelectMode.new()

  Events.connect("cell_left_clicked", self, "cell_left_clicked")
  Events.connect("cell_right_clicked", self, "cell_right_clicked")
  Events.connect("hovered_cell_updated", self, "hovered_cell_updated")
  Events.connect("selected_entity_updated", self, "selected_entity_updated")
  Events.connect("dragged_cell_updated", self, "dragged_cell_updated")
  Events.connect("dragged_cell_started", self, "dragged_cell_started")
  Events.connect("dragged_cell_ended", self, "dragged_cell_ended")


func hovered_cell_updated(cell):
  var disabled = game_state.map_grid.astar.is_point_disabled(cell.astar_id)
  var astar_text = "AStar: [%s] %d" % ['X' if disabled else '  ', cell.astar_id]
  $Menus/Left/VBoxContainer/AStarHoverLabel.text = astar_text

  var pawn_name = cell.pawn.character_name if cell.pawn else ""
  $Menus/Left/VBoxContainer/PawnHoverLabel.text = "Pawn: %s" % pawn_name

  var feature_text = cell.feature.to_string() if cell.feature else ""
  $Menus/Left/VBoxContainer/FeatureHoverLabel.text = "Feature: %s" % feature_text

  var color = cell.terrain if cell.terrain else Color(0)
  $Menus/Left/VBoxContainer/TerrainHoverLabel/ColorRect.color = color

  var location_text = cell.location
  $Menus/Left/VBoxContainer/LocationHoverLabel.text = "Location: %s" % location_text


func selected_entity_updated(entity):
  var focus_text = entity

  # TODO: try multiline strings """
  if entity is Pawn:
    focus_text = "%s\n  %s" % [entity.character_name, entity.race]
    for item in entity.items:
      focus_text += "\n%s: %s" % [item, entity.items[item]]

  elif entity is Building:
    focus_text = "Building: %s\n" % entity.type
    focus_text += "  Location: %s\n" % entity.location

  elif entity is Item:
    focus_text = "Item: %s (x%s)\n" % [entity.type, entity.quantity]
    focus_text += "  Location: %s\n" % entity.location
    focus_text += "  Claimed: %s\n" % entity.claimant.character_name if entity.is_claimed() else "No"

  elif entity is Job:
    if entity is BuildJob:
      focus_text = "Build Job\n"
      focus_text += "  %s/100\n" % entity.percent_complete
      focus_text += "  Completable: %s\n" % ("Yes" if entity.completable else "No")
      focus_text += "  Materials: %s\n" % entity.materials_present
    elif entity is HaulJob:
      focus_text = "Haul Job\n"
      focus_text += "  Material: %s\n" % entity.material
      focus_text += "  Quantity: %s\n" % entity.quantity
    else:
      focus_text = "Job\n"

    if entity.sub_jobs.size() > 0:
      focus_text += "Sub-Jobs: %s" % entity.sub_jobs.size()

  $Menus/Left/VBoxContainer/TargetFocus.text = "%s" % focus_text


func cell_left_clicked(cell):
  if mode_controller:
    mode_controller.cell_left_clicked(cell)


func cell_right_clicked(cell):
  if mode_controller:
    mode_controller.cell_right_clicked(cell)


var mode_controller: ModeController
var mode_controllers = {
  Enums.Mode.SELECT: SelectMode,
  Enums.Mode.BUILD: BuildMode,
  Enums.Mode.CHOP: ChopMode,
}


func mode_updated(mode_params):
  mode_controller = mode_controllers[mode_params.mode].new(game_state)


func dragged_cell_updated(origin_cell: MapCell, dragged_to_cell: MapCell):
  if not mode_controller: return
  mode_controller.remove_job_markers()

  if origin_cell and dragged_to_cell:
    for marker in mode_controller.get_job_markers_between(origin_cell, dragged_to_cell):
      add_child(marker)


func dragged_cell_ended(_1, _2):
  if not mode_controller: return
  mode_controller.execute()


func dragged_cell_started(_1, _2):
  if not mode_controller: return
