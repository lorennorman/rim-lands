extends Spatial

func _ready():
  var active_tree
  match randi() % 10:
    1: active_tree = $tree_simple
    2: active_tree = $tree_tall
    _: active_tree = $tree_oak
  active_tree.visible = true

  var rng = RandomNumberGenerator.new()
  rng.randomize()
  var translation_offset = Vector3(rng.randf_range(-.5,.5), 0, rng.randf_range(-.5,.5))
  active_tree.translate(translation_offset)
