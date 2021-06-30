extends Spatial

var cell: MapCell setget set_cell
var building: Resource
onready var wall_model = $WallModel


func _ready():
  assert(building or cell, "BuildingModel became _ready() without a Building nor a Cell")
  if not cell:
    self.cell = building.map_cell
  cell.update_neighborspace()
  neighborspace_updated(cell)


func set_cell(new_cell):
  cell = new_cell
  translation = cell.position
  cell.connect("neighborspace_updated", self, "neighborspace_updated")
  # cell.update_neighborspace()
  neighborspace_updated(cell)


func neighborspace_updated(_cell):
  if wall_model:
    wall_model.neighbors = cell.neighborspace
