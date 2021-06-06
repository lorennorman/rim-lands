extends Spatial

const Wall = preload("res://buildings/walls/none.tscn")
var buildings = {}

func _ready():
  var _ba = Events.connect("building_added", self, "on_building_added")

func on_building_added(building):
  var wall = Wall.instance()
  buildings[building.key] = wall
  wall.translation = building.map_cell.position
  add_child(wall)
