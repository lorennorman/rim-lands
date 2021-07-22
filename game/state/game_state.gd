extends Resource
class_name GameState

export(Array, Resource) var pawns
export(Array, Resource) var jobs
export(Array, Resource) var buildings
export(Array, Resource) var items
export(Resource) var map_grid
var gui_state := GUIState.new()


var _jc = Events.connect("job_completed", self, "complete_job")


### Actions API

## use these to choose when to "turn the state on/off"
func buildup():
  # remake ephemeral connections
  # rebuild map
  map_grid.astar = AStar.new()
  map_grid.generate_cells(true)

  # build everybody up
  for pawn in pawns: buildup_pawn(pawn)
  for item in items: buildup_item(item)
  for job in jobs: buildup_job(job)
  for building in buildings: buildup_building(building)

  # signal for all existing resources
  for pawn in pawns: Events.emit_signal("pawn_added", pawn)
  for item in items: Events.emit_signal("item_added", item)
  for job in jobs: Events.emit_signal("job_added", job)
  for building in buildings: Events.emit_signal("building_added", building)


func teardown():
  # yolo deletion: tell the whole world to teardown
  # results in instant queue_free() on all scene tree listeners
  Events.emit_signal("game_state_teardown")

  # clear your local stuff
  # may be superfluous, must study godot reference counting or profile
  jobs.clear()
  pawns.clear()
  map_grid.teardown()


## Pawns
func add_pawn(pawn: Pawn):
  pawns.push_back(pawn)
  buildup_pawn(pawn)
  Events.emit_signal("pawn_added", pawn)


func buildup_pawn(pawn):
  assert(map_grid, "Map must be set before Pawns can be added")
  assert(pawn.location, "Pawn must have a location to be added to the game")
  map_grid.set_pawn(pawn.location, pawn)


func destroy_pawn(pawn, erase=true):
  if erase: pawns.erase(pawn)
  pawn.removed = true
  map_grid.lookup_cell(pawn.location).pawn = null
  Events.emit_signal("pawn_removed", pawn)


## Jobs
func add_job(job: Job):
  buildup_job(job)
  jobs.push_back(job)
  Events.emit_signal("job_added", job)


func buildup_job(job):
  assert(map_grid, "Map must be set before Jobs can be added")
  var cell = map_grid.lookup_cell(job.location)
  if not cell.can_take_job(job):
    printerr("Attempted to assign job to ineligible cell: %s -> %s" % [job, cell])

  job.map_cell = cell
  # unless i have a parent and they occupy this cell...
  if not (job.parent and job.map_cell == job.parent.map_cell):
    # ...i occupy this cell
    cell.feature = job

  # FIXME: nested add_job for sub-jobs, something isn't right here
  #   won't the subjobs get saved/loaded normally, and thus not need the
  #   parent job to add them?
  if not job.can_be_completed():
    for sub_job in job.sub_jobs:
      add_job(sub_job)


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
  elif item.owner is Pawn:
    item.owner.add_item(item)
  elif item.owner is Job:
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
