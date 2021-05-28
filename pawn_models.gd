extends Spatial

const PawnModel = preload("pawn_model.tscn")

func _ready():
  var _pawn_added = Events.connect("pawn_added", self, "add_pawn")

func add_pawn(pawn: Pawn) -> void:
  var pawn_model = PawnModel.instance()
  pawn_model.pawn = pawn
  add_child(pawn_model)
