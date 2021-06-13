extends ViewportContainer

var pawn: Pawn

func _ready():
  assert(pawn, "PawnDirectoryEntry called _ready() without a Pawn set.")
  $Viewport/PawnModel.pawn = pawn
  $Viewport/PawnModel.translation = Vector3.ZERO
