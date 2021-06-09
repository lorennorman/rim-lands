extends Spatial

const Simulator = preload("res://game/simulator.gd")

var game_state: GameState
var sim: Simulator
var state = "loading"


func _ready():
  $MapTerrain.input_camera = $Camera

  var _nwrError = Events.connect("new_world_requested", self, "new_world")
  var _lwrError = Events.connect("load_world_requested", self, "load_world")
  var _swrError = Events.connect("save_world_requested", self, "save_world")

  load_world()


func replace_game_state(new_game_state):
  game_state = new_game_state

  $MapTerrain.game_state = game_state
  $GUI.game_state = game_state
  $GUI.gui_state = game_state.gui_state
  sim = Simulator.new(game_state)
  state = "simulating"
  print("Simulating!")


func _process(delta):
  match state:
    "simulating": if sim: sim._process(delta)


func load_world():
  state = "loading"
  $MapTerrain.game_state = null
  if game_state: game_state.teardown()
  game_state = null

  # state is rehydrated by its own setters during load
  var loaded_game_state = ResourceLoader.load("res://savegames/savegame1.tres", "GameState", true)

  replace_game_state(loaded_game_state)


func save_world():
  if ResourceSaver.save("res://savegames/savegame.tres", game_state) != OK:
    printerr("Error saving GameState")


func new_world():
  state = "loading"
  $MapTerrain.game_state = null
  if game_state: game_state.teardown()
  game_state = null

  # Create the world with GameState methods
  var generated_game_state = GameState.new()

  # MapGrid
  var map_grid = MapGrid.new()
  generated_game_state.map_grid = map_grid

  # Put pawns onto the map
  generated_game_state.make_pawn("Dwarf", "Thorben", "31,21")
  generated_game_state.make_pawn("Elf", "Zah Dir", "31,22")
  generated_game_state.make_pawn("Elf", "Zah Dra", "32,21")
  generated_game_state.make_pawn("Human", "Fardinand", "32,22")

  # Add some jobs to the job list
  # Move orders
  # generated_game_state.make_job(Enums.Jobs.MOVE, "20,20")
  # generated_game_state.make_job(Enums.Jobs.MOVE, "22,50")
  # generated_game_state.make_job(Enums.Jobs.MOVE, "50,22")
  # generated_game_state.make_job(Enums.Jobs.MOVE, "63,51")

  # Build orders
  # generated_game_state.make_job(Enums.Jobs.BUILD, "25,22", Enums.Buildings.WALL)
  # generated_game_state.make_job(Enums.Jobs.BUILD, "26,22", Enums.Buildings.WALL)
  # generated_game_state.make_job(Enums.Jobs.BUILD, "30,22", Enums.Buildings.WALL)
  # generated_game_state.make_job(Enums.Jobs.BUILD, "32,22", Enums.Buildings.WALL)
  # generated_game_state.make_job(Enums.Jobs.BUILD, "35,22", Enums.Buildings.WALL)

  # Unimplemented orders
  #  make_job("Mine Ore", "55,55")
  #  make_job("Till Soil", "30,60")

  replace_game_state(generated_game_state)
