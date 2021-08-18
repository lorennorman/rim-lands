extends Spatial

const Simulator = preload("res://game/simulator.gd")

var game_state: GameState
var sim: Simulator
var simulator_state = "loading" setget set_simulator_state
func set_simulator_state(new_state):
  if simulator_state != new_state:
    simulator_state = new_state
    Events.emit_signal("simulator_state_updated", simulator_state)


func _ready():
  $MapTerrain.input_camera = $Camera

  Events.connect("new_world_requested", self, "new_world")
  Events.connect("new_game_requested", self, "new_game")
  Events.connect("load_world_requested", self, "load_world")
  Events.connect("save_world_requested", self, "save_world")
  Events.connect("pause_requested", self, "pause_requested")

  var state = StateGenerator.state_from_template()
  print(state.map_grid.forests.size())

  # new_world()
  # load_world("res://scenarios/medium_party_busy.tres")

  # Tests:
  # test_core_pawn_item_haul_build()


func new_game(map_grid):
  self.simulator_state = "loading"
  clear_running_game_state()
  yield(get_tree(), "idle_frame") # superstition

  var new_game_state = GameState.new()
  new_game_state.map_grid = map_grid

  start_running_game_state(new_game_state)

  # get the default pawn trio
  var pawns = Factory.Pawns.default_pawns()
  # find a good place for them on the map
  # TODO: have to add pawns AFTER game is loaded because map_grid.astar is used here
  #   support lazily-resolved locations for pawns items and buildings
  var start_locations = map_grid.find_good_starting_positions(pawns.size())
  # add them
  for index in pawns.size():
    pawns[index].location = start_locations[index].location
    new_game_state.add_pawn(pawns[index])


func clear_running_game_state():
  $MapTerrain.input_state = "paused"
  $MapTerrain.map_grid = null
  if game_state:
    game_state.teardown()
    game_state = null


func start_running_game_state(new_game_state: GameState):
  game_state = new_game_state
  game_state.buildup()

  $MapTerrain.map_grid = game_state.map_grid
  $MapTerrain.input_state = "listening"
  $GUI.game_state = game_state
  sim = Simulator.new(game_state)
  self.simulator_state = "simulating"
  print("Simulating!")


func pause_requested(): set_pause(true)


func _input(event):
  if event.is_action_pressed("ui_select"):
    set_pause(not get_tree().paused)


func set_pause(new_paused):
  get_tree().paused = new_paused
  self.simulator_state = "paused" if get_tree().paused else "simulating"


func _process(delta):
  match simulator_state:
    "simulating": if sim: sim._process(delta)


func load_world(game_state_file="res://savegames/savegame.tres"):
  self.simulator_state = "loading"
  clear_running_game_state()
  yield(get_tree(), "idle_frame") # superstition

  # TODO: filesystem safety concerns? directory locking?
  var loaded_game_state = ResourceLoader.load(game_state_file, "Resource", false)

  # from experience: we should not edit the GameState that is loaded, directly
  # else we suffer from inability to unload/reload resources (might be a bug)
  # instead we'll new up a GameState and duplicate the sub-resources
  var duplicated_game_state := duplicate_game_state(loaded_game_state)
  start_running_game_state(duplicated_game_state)


func duplicate_game_state(game_state_to_copy) -> GameState:
  # gets new()'d so we have a proper GameState class and our casting works
  var duplicated_game_state = GameState.new()
  # use duplicate() on the sub-resources
  # keep this up to date as sub-resources are added
  duplicated_game_state.pawns = []
  for pawn in game_state_to_copy.pawns:
    duplicated_game_state.pawns.push_back(pawn.duplicate())
  duplicated_game_state.jobs = []
  for job in game_state_to_copy.jobs:
    duplicated_game_state.jobs.push_back(job.duplicate())
  for building in game_state_to_copy.buildings:
    duplicated_game_state.buildings.push_back(building.duplicate())
  duplicated_game_state.map_grid = game_state_to_copy.map_grid.duplicate()

  return duplicated_game_state


func save_world(game_state_file="res://savegames/savegame.tres"):
  if ResourceSaver.save(game_state_file, game_state) != OK:
    printerr("Error saving GameState")


func new_world():
  yield(load_world("res://scenarios/new_world.tres"), "completed")


# Test Ideas:
# func test_nightly_attacks_from_portal():
# func test_humans_agriculture():
# func test_dwarves_ranching():
# func test_elves_foraging_cultivating():
# func test_road_guardhouse_encounters():
# func test_dwarves_tunneling_mining_smelting():

# func test_tavern_service_customers_economy():
# func test_elven_magic_school_classes():

# func test_encounter_with_a_marshal():

# func test_void_pawn_equipment_combat():
# func test_rim_orcs_encounter_cycle():
func test_core_pawn_item_haul_build():
  yield(load_world("res://scenarios/new_world.tres"), "completed")

  game_state.add_job(
    BuildJob.new({
      "location": "30,14",
      "building_type": Enums.Buildings.WALL,
      "materials_required": {
        Enums.Items.LUMBER: 20
      }
    }))

  game_state.add_item(Item.new({
    "type": Enums.Items.LUMBER,
    "location": "29,14",
    "quantity": 30
  }))
  # game_state.add_item(Item.new({
  #   "type": Enums.Items.LUMBER,
  #   "location": "25,17",
  #   "quantity": 30
  # }))
  # game_state.add_item(Item.new({
  #   "type": Enums.Items.LUMBER,
  #   "location": "26,18",
  #   "quantity": 30
  # }))
  # game_state.add_item(Item.new({
  #   "type": Enums.Items.LUMBER,
  #   "location": "24,20",
  #   "quantity": 30
  # }))
