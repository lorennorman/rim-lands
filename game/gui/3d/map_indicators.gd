extends Spatial

func _ready():
  Events.connect("hovered_cell_updated", self, "hovered_cell_updated")
  Events.connect("selected_cell_updated", self, "selected_cell_updated")


func hovered_cell_updated(new_hovered_cell):
  $HoverIndicator.translation = new_hovered_cell.position

  
func selected_cell_updated(new_selected_cell):
  $SelectIndicator.translation = new_selected_cell.position
