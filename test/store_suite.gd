# empty state into a fresh store
func new_store(): return GameStore.new(GameState.new())


func test_store_constructor():
  return new_store()


func test_add_pawn():
  var store = new_store()
  var pawn = Pawn.new()
  # var spy = get_spy("pawn_added")
  # store.connect("pawn_added", spy, "spy")
  assert(store.game_state.pawns.size() == 0, "Pawns should be empty before add")
  store.add_pawn(pawn)
  assert(store.game_state.pawns.size() == 1, "Pawns should contain 1 after add")

  # assert(spy.called, "pawn_added was not emitted by the store")
  # assert(spy.arg_1 == pawn, "pawn_added did not emit the added pawn")
  return true
