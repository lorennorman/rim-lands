extends Control

var test_names = [
  "test_thing_a",
  "test_thing_c",
  "test_thing_q"
]


func _ready():
  # enqueue all tests to run
  var test_labels = []
  for name in test_names:
    # observer label for each test
    var label = TestLabel.new(name, funcref(self, name))
    test_labels.push_back(label)
    $MarginContainer/VBoxContainer/TestRuns.add_child(label)

  for test in test_labels:
    var return_value = test.run()
    if return_value is GDScriptFunctionState && return_value.is_valid():
      yield(return_value, "completed")


func test_thing_a():
  return false


func test_thing_c():
  return true


func test_thing_q():
  printerr("error!")


class TestLabel:
  extends Label

  var test_name
  var test_func

  func _init(new_test_name, new_test_func):
    test_name = new_test_name
    test_func = new_test_func

    text = "[ ]: %s " % test_name

  func run():
    var return_value = test_func.call_func()

    if return_value:
      text = "[.]: %s " % test_name
    else:
      text = "[F]: %s " % test_name

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
  # load a state:
  var game_state = {}
  # then add:
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
