tool
extends Spatial

export(Array, bool) var neighbors = [true, true, true, true] setget set_neighbors
func set_neighbors(new_neighbors):
  assert(new_neighbors.size() == 4, "Wall neighbors set with a non-size-4 array.")
  neighbors = new_neighbors
  update_wall_visibility()

func _ready(): update_wall_visibility()

func update_wall_visibility():
  $North.visible = neighbors[0]
  $East.visible = neighbors[1]
  $South.visible = neighbors[2]
  $West.visible = neighbors[3]

  $None.visible = not (neighbors[0] or neighbors[1] or neighbors[2] or neighbors[3])
