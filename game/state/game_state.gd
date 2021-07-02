extends Resource
class_name GameState

export(Array, Resource) var pawns
export(Array, Resource) var jobs
export(Array, Resource) var buildings
export(Array, Resource) var items
export(Resource) var map_grid
var gui_state := GUIState.new()


var _jc = Events.connect("job_completed", self, "complete_job")



func add_pawn(pawn: Pawn, location: String):
  assert(map_grid, "Map must be set before Pawns can be added")
  pawns.push_back(pawn)
  map_grid.set_pawn(location, pawn)
  Events.emit_signal("pawn_added", pawn)


func destroy_pawn(pawn, erase=true):
  if erase: pawns.erase(pawn)
  pawn.removed = true
  map_grid.lookup_cell(pawn.location).pawn = null
  Events.emit_signal("pawn_removed", pawn)


func add_job(job: Job):
  assert(map_grid, "Map must be set before Jobs can be added")
  var cell = map_grid.lookup_cell(job.location)
  if cell.can_take_job(job):
    job.map_cell = cell
    cell.feature = job
    Events.emit_signal("job_added", job)

    if not job.can_be_completed():
      for sub_job in job.sub_jobs:
        add_job(sub_job)

    jobs.push_back(job)

  else:
    printerr("Attempted to assign job to ineligible cell: %s -> %s" % [job, cell])


func complete_job(job, erase=true):
  match job.job_type:
    Enums.Jobs.BUILD:
      make_building(job.building_type, job.location)

  if erase: jobs.erase(job)
  job.removed = true
  Events.emit_signal("job_removed", job)


func add_building(building, location):
  buildings.push_back(building)
  var cell = map_grid.lookup_cell(location)
  building.map_cell = cell
  cell.feature = building
  Events.emit_signal("building_added", building)


func add_item(item):
  items.push_back(item)
  var cell = map_grid.lookup_cell(item.location)
  item.map_cell = cell
  cell.feature = item
  Events.emit_signal("item_added", item)


func destroy_item(item):
  items.erase(item)
  Events.emit_signal("item_removed", item)


func find_closest_available_material_to(material_type, origin_cell: MapCell):
  var closest_item = null
  var distance = 100_000
  for item in items:
    if item.type != material_type or item.is_claimed(): continue

    var item_distance = map_grid.get_move_path(origin_cell, item.map_cell).size()
    if item_distance < distance:
      closest_item = item
      distance = item_distance

  return closest_item


func pawn_pick_up_material_quantity(pawn: Pawn, material, quantity: int):
  # make a new item
  var taken_item = material.duplicate()
  # add quantity to the new from the old
  taken_item.quantity = quantity
  material.quantity -= quantity
  # add item to pawn
  pawn.add_item(taken_item)
  # if remaining quantity is zero, remove item from map
  if material.quantity <= 0:
    destroy_item(material)


func pawn_drop_material(pawn: Pawn, material, quantity):
  if pawn.has_item(material):
    pawn.remove_item(material, quantity)
    var new_item = material.duplicate()
    new_item.location = pawn.location
    new_item.quantity = quantity
    add_item(new_item)

func teardown():
  # yolo deletion: tell the whole world to teardown
  # results in instant queue_free() on all scene tree listeners
  Events.emit_signal("game_state_teardown")

  # clear your local stuff
  # may be superfluous, must study godot reference counting or profile
  jobs.clear()
  pawns.clear()
  map_grid.teardown()


func buildup():
  # remake ephemeral connections
  # rebuild map and put resources on it
  map_grid.generate_cells()
  for pawn in pawns:
    map_grid.set_pawn(pawn.location, pawn)

  for job in jobs:
    job.map_cell = map_grid.lookup_cell(job.location)

  for building in buildings:
    var cell = map_grid.lookup_cell(building.location)
    building.map_cell = cell
    cell.feature = building

  # signal for all existing resources
  for pawn in pawns:
    Events.emit_signal("pawn_added", pawn)

  for job in jobs:
    Events.emit_signal("job_added", job)

  for building in buildings:
    Events.emit_signal("building_added", building)


# Helpers
func make_pawn(type, name, location) -> void:
  var pawn = Pawn.new()
  pawn.race = type
  pawn.character_name = name
  add_pawn(pawn, location)


func make_job(job_type, job_location, job_params) -> void:
  var job = Job.new()
  job.job_type = job_type
  job.location = job_location
  if job_params: job.params = job_params
  add_job(job)


func make_building(building_type, building_location) -> void:
  var building = Building.new()
  building.type = building_type
  building.location = building_location

  add_building(building, building_location)


func make_item(item_type, item_location) -> void:
  var item = Item.new({
    "type": item_type,
    "location": item_location,
  })

  add_item(item)
