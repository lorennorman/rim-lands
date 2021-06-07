extends Spatial

const Wall = preload("res://buildings/walls/4_way.tscn")
var building_models = {}

func _ready():
  var _ba = Events.connect("building_added", self, "on_building_added")
  var _br = Events.connect("building_removed", self, "on_building_removed")

func on_building_added(building):
  var wall = Wall.instance()
  building_models[building.key] = wall
  wall.translation = building.map_cell.position
  # configure wall model based on wall's 4-way neighborspace
  # register listener for when wall's neighborspace changes
  # ask all walls to check their neighborspaces

  add_child(wall)

func on_building_removed(building):
  var building_model = building_models[building.key]
  if building_model:
    building_models.erase(building.key)
    remove_child(building_model)
    building_model.queue_free()
