extends Spatial

const BuildingModel = preload("./building_model.gd")
var building_models = {}

func _ready():
  var _ba = Events.connect("building_added", self, "on_building_added")
  var _br = Events.connect("building_removed", self, "on_building_removed")

func on_building_added(building):
  var building_model = BuildingModel.new()
  building_model.cell = building.map_cell
  building_models[building.key] = building_model
  add_child(building_model)
  update_neighborspaces()

func on_building_removed(building):
  var building_model = building_models[building.key]
  building_models.erase(building.key)
  remove_child(building_model)
  building_model.queue_free()
  update_neighborspaces()

func update_neighborspaces():
  for building_model in building_models.values():
    building_model.cell.update_neighborspace()
