extends Spatial

const PawnModel = preload("pawn_model.tscn")

var pawn_models = {}

func _ready():
  var _pa = Events.connect("pawn_added", self, "add_pawn")
  var _pr = Events.connect("pawn_removed", self, "remove_pawn")

func add_pawn(pawn: Pawn) -> void:
  var pawn_model = PawnModel.instance()
  pawn_model.pawn = pawn
  pawn_models[pawn.key] = pawn_model
  add_child(pawn_model)

func remove_pawn(pawn: Pawn) -> void:
  var pawn_model = pawn_models[pawn.key]
  pawn_models.erase(pawn.key)
  pawn_model.queue_free()
  remove_child(pawn_model)
