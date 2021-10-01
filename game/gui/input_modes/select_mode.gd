extends ModeController
class_name SelectMode

var selected_cell: MapCell
var selected_entity


func cancel(_cell):
  # TODO: deselect things
  pass


func confirm(cell):
  if selected_cell != cell:
    # new cell clicked
    selected_cell = cell
    selected_entity = null
    Events.emit_signal("selected_cell_updated", cell)

  selected_entity = next_selectable_entity(cell, selected_entity)
  Events.emit_signal("selected_entity_updated", selected_entity)


func consider_from_to(_start, _end):
  # TODO: selection square? highlight lasso'd selectable items?
  pass


func confirm_from_to(_start, _end):
  # TODO: group-selection routine
  pass

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
