extends "./test.gd"

# empty state into a fresh store
func new_store(): return GameStore.new(GameState.new())


func test_store_constructor():
  expect(new_store(), "state/store constructor failed")


func test_add_pawn():
  var store = new_store()
  var pawn = Pawn.new()
  var spy = spy_on(store, "pawn_added")
  expect(store.game_state.pawns.size() == 0, "Pawns should be empty before add")
  store.add_pawn(pawn)
  expect(store.game_state.pawns.size() == 1, "Pawns should contain 1 after add")

  expect(spy.called, "pawn_added was not emitted by the store")
  expect(spy.arg_1 == pawn, "pawn_added did not emit the added pawn")
