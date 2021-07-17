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
  Events.connect("cell_left_clicked", self, "cell_left_clicked")
  Events.connect("cell_right_clicked", self, "cell_right_clicked")
  Events.connect("cell_hovered", self, "cell_hovered")
  Events.connect("left_drag_started", self, "left_drag_started")
  Events.connect("left_drag_ended", self, "left_drag_ended")

  Events.connect("set_mode", self, "set_mode")


func set_mode(mode_params):
  mode = mode_params.mode

  if mode == Enums.Mode.BUILD:
    building = mode_params.building
    if building == Enums.Buildings.WALL:
      pass
  elif mode == Enums.Mode.SELECT:
    pass

  Events.emit_signal("mode_updated", mode_params)

func cell_left_clicked(cell):
  # new cell clicked
  if selected_cell != cell:
    selected_cell = cell
    Events.emit_signal("selected_cell_updated", cell)

  selected_entity = next_selectable_entity(cell, selected_entity)
  Events.emit_signal("selected_entity_updated", selected_entity)


func next_selectable_entity(cell, current_selection):
  var entities = []
  if cell.pawn: entities.push_back(cell.pawn)
  if cell.feature: entities.push_back(cell.feature)
  entities.push_back(cell.terrain)

  if not current_selection or current_selection is Color:
    return entities[0]
  elif current_selection == cell.pawn:
    return entities[1]
  elif current_selection == cell.feature:
    return entities[-1]


func cell_right_clicked(_cell):
  if selected_entity is Pawn:
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
