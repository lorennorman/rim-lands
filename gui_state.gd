extends Resource

class_name GUIState

var selected_entity
var selected_cell: MapCell

func _init():
  var _cl = Events.connect("cell_left_clicked", self, "handle_cell_lclicked")
  var _cr = Events.connect("cell_right_clicked", self, "handle_cell_rclicked")
  var _ch = Events.connect("cell_hovered", self, "handle_cell_hovered")

  var _sm = Events.connect("set_mode", self, "handle_set_mode")


func handle_set_mode(mode_params):
  var mode = mode_params.mode

  if mode == Enums.Jobs.BUILD:
    var building = mode_params.building
    if building == Enums.Buildings.WALL:
      Events.emit_signal("mode_updated", mode_params)

func handle_cell_lclicked(cell):
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


func handle_cell_rclicked(_cell):
  if selected_entity is Pawn:
    # sim.make_job(Enums.Jobs.MOVE, cell.location, selected_entity)
    pass


var hovered_cell
func handle_cell_hovered(cell):
  if cell == hovered_cell: return
  assert(cell, "Invalid cell passed to handle_cell_hovered: %s" % cell)
  hovered_cell = cell
  Events.emit_signal("hovered_cell_updated", cell)
