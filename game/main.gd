extends Spatial

const Simulator = preload("res://game/simulator.gd")

var game_state: GameState
var sim: Simulator
var state = "loading"


func _ready():
  $MapTerrain.input_camera = $Camera

  Events.connect("new_world_requested", self, "new_world")
  Events.connect("load_world_requested", self, "load_world")
  Events.connect("save_world_requested", self, "save_world")

  load_world()


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
  state = "simulating"
  print("Simulating!")


func _process(delta):
  match state:
    "simulating": if sim: sim._process(delta)


func load_world(game_state_file=null):
  state = "loading"
  clear_running_game_state()
  yield(get_tree(), "idle_frame") # superstition

  if not game_state_file:
    # TODO: make a popover file load menu
    # preset savegames:
    # game_state_file = "small_empty.tres"
    # game_state_file = "small_solo.tres"
    # game_state_file = "small_party.tres"
    game_state_file = "small_party_busy.tres"
    # game_state_file = "medium_party_busy.tres"
    # game_state_file = "large_party_busy.tres"

  var loaded_game_state = ResourceLoader.load("res://savegames/%s" % game_state_file, "Resource", false)
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
  duplicated_game_state.map_grid = game_state_to_copy.map_grid.duplicate()

  return duplicated_game_state

func save_world():
  if ResourceSaver.save("res://savegames/savegame.tres", game_state) != OK:
    printerr("Error saving GameState")


func new_world():
  load_world("new_world.tres")
