extends Object


func action_add_building(store, payload):
  var building = Building.new(payload)
  store.game_state.buildings.push_back(building)
  StateActivator.activate_building(building, store.map)
  store.emit_signal("building_added", building)
