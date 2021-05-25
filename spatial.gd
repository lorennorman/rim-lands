extends Spatial

const Simulator = preload("simulator.gd")
const PawnModel = preload("pawn_model.tscn")
const Pawn = preload("pawn.gd")
const Job = preload("job.gd")

onready var Map = $Map
var sim

func _ready():
  var _start_timer = Events.connect("start_timer", self, "handle_start_timer")
  Map.input_camera = $Camera
  var _node_rclicked = Events.connect("node_rclicked", self, "handle_cell_rclicked")
  var _node_lclicked = Events.connect("node_lclicked", self, "handle_cell_lclicked")
  var _node_hovered = Events.connect("node_hovered", self, "handle_cell_hovered")

  # Create the world
  sim = Simulator.new()
  sim.map = Map

  var _pawn_added = Events.connect("pawn_added", self, "add_pawn")
  var _job_added = Events.connect("job_added", $GUI, "add_job")

  # Put pawns onto the map
  sim.make_pawn("Dwarf", "Thorben", "31,21")
  sim.make_pawn("Elf", "Zah Dir", "31,22")
  sim.make_pawn("Elf", "Zah Dra", "32,21")
  sim.make_pawn("Human", "Fardinand", "32,22")

  # Add some jobs to the job list
  sim.make_job(Enums.Jobs.MOVE, "20,20")
  sim.make_job(Enums.Jobs.MOVE, "22,50")
  sim.make_job(Enums.Jobs.MOVE, "50,22")
  # sim.make_job(Enums.Jobs.MOVE, "63,51")
  sim.make_job(Enums.Jobs.BUILD, "30,25")
#  make_job("Mine Ore", "55,55")
#  make_job("Till Soil", "30,60")

  # Start the sim
  yield(get_tree().create_timer(0.5), "timeout")
  sim.start()

func handle_start_timer(timer):
  add_child(timer)
  yield(timer, "timeout")
  remove_child(timer)

func add_pawn(pawn):
  var pawn_scene = PawnModel.instance()
  pawn_scene.pawn = pawn
  add_child(pawn_scene)

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
