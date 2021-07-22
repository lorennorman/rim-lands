extends Object

# convert clicks and hovers into drags
var hovered_cell: MapCell
var dragged_cell: MapCell
var left_dragging

func _init():
  Events.connect("cell_hovered", self, "cell_hovered")
  Events.connect("left_drag_started", self, "left_drag_started")
  Events.connect("left_drag_ended", self, "left_drag_ended")


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
