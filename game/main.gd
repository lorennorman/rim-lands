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
  Events.connect("load_world_requested", self, "load_world")
  Events.connect("save_world_requested", self, "save_world")
  Events.connect("pause_requested", self, "pause_requested")

  new_world()
  # load_world()


func clear_running_game_state():
  $MapTerrain.game_state = null
  if game_state:
    game_state.teardown()
    game_state = null


func start_running_game_state(new_game_state: GameState):
  game_state = new_game_state
  game_state.buildup()

  $MapTerrain.game_state = game_state
  $GUI.game_state = game_state
  $GUI.gui_state = game_state.gui_state
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

  game_state.add_job(
    BuildJob.new({
      "location": "25,20",
      "building_type": Enums.Buildings.WALL,
      "materials_required": {
        Enums.Items.LUMBER: 20
      }
    }))

  game_state.add_item(Item.new({
    "type": Enums.Items.LUMBER,
    "location": "25,15",
    "quantity": 20
  }))
  game_state.add_item(Item.new({
    "type": Enums.Items.LUMBER,
    "location": "25,17"
  }))
  game_state.add_item(Item.new({
    "type": Enums.Items.LUMBER,
    "location": "26,18"
  }))
  game_state.add_item(Item.new({
    "type": Enums.Items.LUMBER,
    "location": "24,20"
  }))
