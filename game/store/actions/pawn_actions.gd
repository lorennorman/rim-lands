extends Object

func action_add_pawn(store, payload):
  var pawn = Pawn.new(payload)
  store.game_state.pawns.push_back(pawn)
  StateActivator.activate_pawn(pawn, store.map)
  # signal broadly
  store.emit_signal("pawn_added", pawn)


func action_update_pawn(_store, payload):
  var pawn: Pawn = payload["pawn"]
  var updates = payload["updates"]

  for key in updates.keys():
    pawn[key] = updates[key]

  pawn.emit_signal("updated", pawn)


func action_destroy_pawn(store, pawn):
  store.game_state.pawns.erase(pawn)
  StateActivator.deactivate_pawn(pawn, store.map)
  store.emit_signal("pawn_removed", pawn)
