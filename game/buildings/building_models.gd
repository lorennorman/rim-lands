extends Spatial

const BuildingModel = preload("./building_model.gd")
var building_models = {}

func _ready():
  Events.connect("building_added", self, "building_added")
  Events.connect("building_removed", self, "building_removed")
  Events.connect("game_state_teardown", self, "teardown")

func building_added(building):
  var building_model = BuildingModel.new()
  building_model.cell = building.map_cell
  building_models[building.key] = building_model
  add_child(building_model)
  update_neighborspaces()


func building_removed(building):
  var building_model = building_models[building.key]
  building_models.erase(building.key)
  building_model.queue_free()
  update_neighborspaces()


func update_neighborspaces():
  for building_model in building_models.values():
    building_model.cell.update_neighborspace()


func teardown():
  for building_model in building_models.values(): building_model.queue_free()
  building_models.clear()
