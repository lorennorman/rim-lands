extends Spatial

var forest setget set_forest
func set_forest(new_forest):
  forest = new_forest
  translation = forest.position


func _ready():
  var active_tree
  match randi() % 10:
    1: active_tree = $tree_simple
    2: active_tree = $tree_tall
    _: active_tree = $tree_oak
  active_tree.visible = true

  var rng = RandomNumberGenerator.new()
  rng.randomize()
  var translation_offset = Vector3(rng.randf_range(-.25,.25), 0, rng.randf_range(-.25,.25))
  active_tree.translate(translation_offset)
  scale = Vector3.ONE * rng.randf_range(.85, 1.15)
