extends Reference
class_name GameStore

var game_state

func _init(new_game_state):
  game_state = new_game_state

signal pawn_added(pawn)
func add_pawn(new_pawn: Pawn):
  # pass
  # gather resources
  # check premises
  # mutate state
  game_state.pawns.push_back(new_pawn)
  # signal broadly
  emit_signal("pawn_added", new_pawn)
