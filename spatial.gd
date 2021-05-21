extends Spatial

const Simulator = preload("simulator.gd")
const PawnModel = preload("pawn_model.tscn")
const Pawn = preload("pawn.gd")
const Job = preload("job.gd")
onready var Map = $Map

func _ready():
  Map.input_camera = $Camera
  Events.connect("node_rclicked", self, "handle_node_rclicked")
  Events.connect("node_lclicked", self, "handle_node_lclicked")
  Events.connect("node_hovered", self, "handle_node_hovered")

  # Create the world
  var sim = Simulator.new()
  sim.map = Map

  Events.connect("pawn_added", self, "add_pawn")
  Events.connect("job_added", $GUI, "add_job")

  # Put pawns onto the map
  sim.make_pawn("Dwarf", "Thorben", "51,31")
  sim.make_pawn("Elf", "Zah Dir", "51,32")
  sim.make_pawn("Elf", "Zah Dra", "52,31")
  sim.make_pawn("Human", "Fardinand", "52,32")

  # Add some jobs to the job list
  sim.make_job("Move to", "20,20")
  sim.make_job("Move to", "22,20")
  sim.make_job("Move to", "20,22")
  sim.make_job("Move to", "21,21")
#  make_job("Cut Wood", "35,35")
#  make_job("Mine Ore", "55,55")
#  make_job("Till Soil", "30,60")

  # Start the sim
  yield(get_tree().create_timer(2.0), "timeout")
  sim.start()

func add_pawn(pawn):
  var pawn_scene = PawnModel.instance()
  pawn_scene.pawn = pawn
  add_child(pawn_scene)

var selected_node_key
var selected_bag
var selected_entity
func handle_node_lclicked(node_key):
  if selected_node_key != node_key:
    selected_node_key = node_key

    selected_bag = Map.grid_bags[node_key]
    $SelectIndicator.translation = selected_bag["position"]

    # select next entity: pawn, feature, terrain
    selected_entity = selected_bag["pawn"]
    if not selected_entity:
      selected_entity = selected_bag["feature"]

    if not selected_entity:
      selected_entity = selected_bag["terrain"]

  else:
    if selected_entity is Color:
      return

    if selected_entity == selected_bag["pawn"] and selected_bag["feature"]:
      selected_entity = selected_bag["feature"]
    else:
      selected_entity = selected_bag["terrain"]

  $GUI.selected_entity = selected_entity

func handle_node_rclicked(node_key):
  if selected_entity is Pawn:
    var bag = Map.grid_bags[node_key]


var last_hovered
func handle_node_hovered(node_key):
  if node_key != last_hovered:
    last_hovered = node_key

    if Map.grid_bags.has(node_key):
      var bag = Map.grid_bags[node_key]
      $GUI.hovered_pawn = bag["pawn"]
      $GUI.hovered_feature = bag["feature"]
      $GUI.hovered_terrain = bag["terrain"]

      $HoverIndicator.translation = bag["position"]
