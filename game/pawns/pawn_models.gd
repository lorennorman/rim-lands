extends Spatial

const PawnModel = preload("pawn_model.tscn")

var pawn_models = {}

func _ready():
  Events.connect("pawn_added", self, "add_pawn")
  Events.connect("pawn_removed", self, "remove_pawn")
  Events.connect("game_state_teardown", self, "teardown")


func add_pawn(pawn: Pawn) -> void:
  var pawn_model = PawnModel.instance()
  pawn_model.pawn = pawn
  pawn_models[pawn.key] = pawn_model
  add_child(pawn_model)


func remove_pawn(pawn: Pawn) -> void:
  var pawn_model = pawn_models[pawn.key]
  pawn_models.erase(pawn.key)
  pawn_model.queue_free()


func teardown():
  for pawn_model in pawn_models.values(): pawn_model.queue_free()
  pawn_models.clear()
