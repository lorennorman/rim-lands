extends Resource

class_name GameState

export(Array, Resource) var pawns
export(Array, Resource) var jobs
export(Array, Resource) var buildings
export(Resource) var map_grid
var gui_state := GUIState.new()


var _jc = Events.connect("job_completed", self, "destroy_job")



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


func add_job(job: Job, location: String):
  assert(map_grid, "Map must be set before Jobs can be added")
  var cell = map_grid.lookup_cell(location)
  if cell.can_take_job(job):
    jobs.push_back(job)
    job.map_cell = cell
    Events.emit_signal("job_added", job)


func destroy_job(job, erase=true):
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
  print("adding item: ", item, " at ", item.location)

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
  add_job(job, job_location)

func make_building(building_type, building_location) -> void:
  var building = Building.new()
  building.type = building_type
  building.location = building_location

  add_building(building, building_location)

func make_item(item_type, item_location) -> void:
  var item = Item.new()
  item.type = item_type
  item.location = item_location

  add_item(item)
