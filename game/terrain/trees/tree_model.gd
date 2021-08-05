extends Spatial

func _ready():
  match randi() % 10:
    1: $tree_simple.visible = true
    2: $tree_tall.visible = true
    _: $tree_oak.visible = true
