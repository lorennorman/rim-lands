extends Resource

class_name GUIState

var hovered_cell: MapCell
var dragged_cell: MapCell
var selected_entity
var selected_cell: MapCell
var mode
var building
var left_dragging

func _init():
  var _cl = Events.connect("cell_left_clicked", self, "cell_left_clicked")
  var _cr = Events.connect("cell_right_clicked", self, "cell_right_clicked")
  var _ch = Events.connect("cell_hovered", self, "cell_hovered")
  var _lds = Events.connect("left_drag_started", self, "left_drag_started")
  var _lde = Events.connect("left_drag_ended", self, "left_drag_ended")

  var _sm = Events.connect("set_mode", self, "set_mode")


func set_mode(mode_params):
  mode = mode_params.mode

  if mode == Enums.Jobs.BUILD:
    building = mode_params.building
    if building == Enums.Buildings.WALL:
      Events.emit_signal("mode_updated", mode_params)


func cell_left_clicked(cell):
  # new cell clicked
  if selected_cell != cell:
    selected_cell = cell

    Events.emit_signal("selected_cell_updated", cell)

    # select next entity: pawn, feature, terrain
    selected_entity = selected_cell.pawn
    if not selected_entity:
      selected_entity = selected_cell.feature

    if not selected_entity:
      selected_entity = selected_cell.terrain

  # already-selected cell clicked again
  else:
    if selected_entity is Color:
      return

    if selected_entity == selected_cell.pawn and selected_cell.feature:
      selected_entity = selected_cell.feature
    else:
      selected_entity = selected_cell.terrain

  Events.emit_signal("selected_entity_updated", selected_entity)


func cell_right_clicked(_cell):
  if selected_entity is Pawn:
    # sim.make_job(Enums.Jobs.MOVE, cell.location, selected_entity)
    pass


func cell_hovered(cell):
  if cell == hovered_cell: return
  assert(cell, "Invalid cell passed to handle_cell_hovered: %s" % cell)
  hovered_cell = cell
  Events.emit_signal("hovered_cell_updated", cell)

  if left_dragging:
    if dragged_cell != cell:
      dragged_cell = cell
      Events.emit_signal("dragged_cell_updated", cell)
  elif dragged_cell != null:
    dragged_cell = null
    Events.emit_signal("dragged_cell_updated", null)



func left_drag_started():
  left_dragging = true
  dragged_cell = hovered_cell


func left_drag_ended():
  left_dragging = false
  dragged_cell = null
