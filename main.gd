extends Spatial

const Simulator = preload("simulator.gd")

onready var Map = $Map
var sim

func _ready():
  Map.input_camera = $Camera

  # Create the world with GameState methods
  var game_state = GameState.new()

  # Map
  game_state.map = Map
  # Put pawns onto the map
  game_state.make_pawn("Dwarf", "Thorben", "31,21")
  game_state.make_pawn("Elf", "Zah Dir", "31,22")
  game_state.make_pawn("Elf", "Zah Dra", "32,21")
  game_state.make_pawn("Human", "Fardinand", "32,22")

  # Add some jobs to the job list
  game_state.make_job(Enums.Jobs.BUILD, "20,20")
  game_state.make_job(Enums.Jobs.BUILD, "22,50")
  game_state.make_job(Enums.Jobs.BUILD, "50,22")
  game_state.make_job(Enums.Jobs.BUILD, "63,51")
  game_state.make_job(Enums.Jobs.BUILD, "30,25")
  game_state.make_job(Enums.Jobs.BUILD, "31,21")
  game_state.make_job(Enums.Jobs.BUILD, "31,22")
  game_state.make_job(Enums.Jobs.BUILD, "32,21")
  game_state.make_job(Enums.Jobs.BUILD, "32,22")
  game_state.make_job(Enums.Jobs.BUILD, "30,25")
  #  make_job("Mine Ore", "55,55")
  #  make_job("Till Soil", "30,60")

  # hand over the game state to observers
  $GUI.game_state = game_state
  sim = Simulator.new(game_state)

  # Take a breath, then start the simulation
  # yield(get_tree().create_timer(0.5), "timeout")
  # sim.start()

func _process(delta):
  sim._process(delta)
