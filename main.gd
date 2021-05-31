extends Spatial

const Simulator = preload("simulator.gd")

var game_state: GameState
var sim: Simulator


func _ready():
  $MapTerrain.input_camera = $Camera

  # var _nwrError = Events.connect("new_world_requested", self, "generate_new_world")
  var _lwrError = Events.connect("load_world_requested", self, "load_world")
  # var _swrError = Events.connect("save_world_requested", self, "save_world")

  generate_new_world()


func _process(delta):
  if sim:
    sim._process(delta)


func load_world():
  var loaded_game_state = ResourceLoader.load("res://savegame.tres", "GameState")
  # TODO: rebuild MapTerrain and Cells
  # TODO: noise object? astar details?
  # TODO: reconnect Jobs and Pawns
  replace_game_state(loaded_game_state)


func save_world():
  if ResourceSaver.save("res://savegame.tres", game_state) != OK:
    printerr("Error saving GameState")


func generate_new_world():
  # Create the world with GameState methods
  var generated_game_state = GameState.new()

  # MapGrid
  var map_grid = MapGrid.new()
  map_grid.generate_cells()
  generated_game_state.map_grid = map_grid

  # Put pawns onto the map
  generated_game_state.make_pawn("Dwarf", "Thorben", "31,21")
  generated_game_state.make_pawn("Elf", "Zah Dir", "31,22")
  generated_game_state.make_pawn("Elf", "Zah Dra", "32,21")
  generated_game_state.make_pawn("Human", "Fardinand", "32,22")

  # Add some jobs to the job list
  generated_game_state.make_job(Enums.Jobs.MOVE, "20,20")
  generated_game_state.make_job(Enums.Jobs.MOVE, "22,50")
  generated_game_state.make_job(Enums.Jobs.MOVE, "50,22")
  generated_game_state.make_job(Enums.Jobs.MOVE, "63,51")
  generated_game_state.make_job(Enums.Jobs.MOVE, "30,25")
  generated_game_state.make_job(Enums.Jobs.MOVE, "31,21")
  generated_game_state.make_job(Enums.Jobs.MOVE, "31,22")
  generated_game_state.make_job(Enums.Jobs.MOVE, "32,21")
  # generated_game_state.make_job(Enums.Jobs.BUILD, "32,22")
  # generated_game_state.make_job(Enums.Jobs.BUILD, "30,25")
  #  make_job("Mine Ore", "55,55")
  #  make_job("Till Soil", "30,60")

  replace_game_state(generated_game_state)


func replace_game_state(new_game_state):
  if game_state:
    game_state.teardown()

  game_state = new_game_state
  $MapTerrain.map_grid = game_state.map_grid
  $GUI.game_state = new_game_state
  sim = Simulator.new(new_game_state)
  print("Simulating!")
