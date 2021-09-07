extends Resource
class_name GameState

export(Array, Resource) var pawns
export(Array, Resource) var jobs
export(Array, Resource) var buildings
export(Array, Resource) var items
export(Resource) var map_grid

# todo: factor this out into a game state container
var _sm = Events.connect("set_mode", self, "set_mode")

var mode setget set_mode
func set_mode(mode_params):
  mode = mode_params.mode
  Events.emit_signal("mode_updated", mode_params)

var _jc = Events.connect("job_completed", self, "complete_job")


### Actions API

## use these to choose when to "turn the state on/off"
func buildup():
  pass

func teardown():
  # yolo deletion: tell the whole world to teardown
  # results in instant queue_free() on all scene tree listeners
  Events.emit_signal("game_state_teardown")

  # clear your local stuff
  # may be superfluous, must study godot reference counting or profile
  jobs.clear()
  pawns.clear()
  map_grid.teardown()


## Jobs
func complete_job(job, erase=true):
  match job.job_type:
    Enums.Jobs.BUILD:
      add_building(Building.new({
        type = job.building_type,
        location = job.location
      }))

  if erase: jobs.erase(job)
  job.removed = true
  Events.emit_signal("job_removed", job)


## Buildings
func add_building(building):
  buildings.push_back(building)
  buildup_building(building)
  Events.emit_signal("building_added", building)


func buildup_building(building):
  var cell = map_grid.lookup_cell(building.location)
  building.map_cell = cell
  cell.feature = building


## Forests
func buildup_forest(forest):
  var cell = map_grid.lookup_cell("%d,%d" % [forest.x, forest.z])
  forest["position"] = cell.position
  cell.feature = "Forest"


func destroy_forest(forest_dict):
  var found_forest
  for forest in map_grid.forests:
    if forest.x == forest_dict.x and forest.z == forest_dict.z:
      found_forest = forest
      break

  if found_forest:
    map_grid.forests.erase(found_forest)

    Events.emit_signal("forest_removed", found_forest)
  else:
    printerr("Didn't find a matching forest for %s" % forest_dict)

## Items
func add_item(item):
  items.push_back(item)
  buildup_item(item)
  Events.emit_signal("item_added", item)


func buildup_item(item):
  if item.owner is String:
    var cell = map_grid.lookup_cell(item.location)
    item.map_cell = cell
    cell.add_item(item)
  else:
    item.owner.add_item(item)


func destroy_item(item):
  if item.owner: item.owner.remove_item(item)
  items.erase(item)
  Events.emit_signal("item_removed", item)


func find_closest_available_material_to(material_type, origin_cell: MapCell):
  var closest_item = null
  var distance = 100_000
  for item in items:
    if item.type != material_type or item.is_claimed() or not item.is_on_map(): continue

    var item_distance = map_grid.get_move_path(origin_cell, item.map_cell).size()
    if item_distance < distance:
      closest_item = item
      distance = item_distance

  return closest_item


func transfer_item_from_to(item_type: int, item_quantity: int, from: Resource, to: Resource):
  # check that "from" has enough of this item
  var from_item = from.get_item(item_type)
  assert(from_item, "Attempted to transfer an item the source doesn't have: %s" % item_type)
  assert(from_item.quantity >= item_quantity, "Attempted to transfer more of an item than the source has: %s < %s" % [from_item.quantity, item_quantity])
  from_item.quantity -= item_quantity
  if from_item.quantity <= 0: destroy_item(from_item)

  # check if "to" already has some of this item
  var to_item = to.get_item(item_type)
  if to_item:
    to_item.quantity += item_quantity
  else:
    # do the new
    to_item = Item.new({
      "type": item_type,
      "quantity": item_quantity,
      "owner": to
    })
    add_item(to_item)
