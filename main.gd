extends Spatial

const Simulator = preload("simulator.gd")

onready var Map = $Map
var sim

func _ready():
  var _start_timer = Events.connect("start_timer", self, "handle_start_timer")
  Map.input_camera = $Camera
  var _node_rclicked = Events.connect("node_rclicked", self, "handle_cell_rclicked")
  var _node_lclicked = Events.connect("node_lclicked", self, "handle_cell_lclicked")
  var _node_hovered = Events.connect("node_hovered", self, "handle_cell_hovered")
  var _job_added = Events.connect("job_added", $GUI, "add_job")

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
  game_state.make_job(Enums.Jobs.MOVE, "20,20")
  game_state.make_job(Enums.Jobs.MOVE, "22,50")
  game_state.make_job(Enums.Jobs.MOVE, "50,22")
  # game_state.make_job(Enums.Jobs.MOVE, "63,51")
  game_state.make_job(Enums.Jobs.BUILD, "30,25")
  #  make_job("Mine Ore", "55,55")
  #  make_job("Till Soil", "30,60")

  # Start the sim
  sim = Simulator.new(game_state)
  # sim.game_state = game_state
  yield(get_tree().create_timer(0.5), "timeout")
  sim.start()

func handle_start_timer(timer):
  add_child(timer)
  yield(timer, "timeout")
  remove_child(timer)

var selected_location_key
var selected_cell
var selected_entity
func handle_cell_lclicked(location_key):
  if selected_location_key != location_key:
    selected_location_key = location_key

    selected_cell = Map.map_grid.lookup_cell(location_key)
    $SelectIndicator.translation = selected_cell.position

    # select next entity: pawn, feature, terrain
    selected_entity = selected_cell.pawn
    if not selected_entity:
      selected_entity = selected_cell.feature

    if not selected_entity:
      selected_entity = selected_cell.terrain

  else:
    if selected_entity is Color:
      return

    if selected_entity == selected_cell.pawn and selected_cell.feature:
      selected_entity = selected_cell.feature
    else:
      selected_entity = selected_cell.terrain

  $GUI.selected_entity = selected_entity

func handle_cell_rclicked(location_key):
  if selected_entity is Pawn:
    sim.make_job(Enums.Jobs.MOVE, location_key, selected_entity)


var last_hovered
func handle_cell_hovered(location_key):
  if location_key != last_hovered:
    last_hovered = location_key
    var cell = Map.map_grid.lookup_cell(location_key)
    if cell:
      $GUI.hovered_pawn = cell.pawn
      $GUI.hovered_feature = cell.feature
      $GUI.hovered_terrain = cell.terrain

      $HoverIndicator.translation = cell.position
