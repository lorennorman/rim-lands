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
