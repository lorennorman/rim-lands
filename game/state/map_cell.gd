extends Resource

class_name MapCell

var map_grid

var position: Vector3
var disabled: bool
var astar_id: int
var location: String
var x setget , get_x
func get_x(): return position.x-0.5
var z setget , get_z
func get_z(): return position.z-0.5

var pawn: Pawn
var feature
var terrain

var neighborspace = [false, false, false, false]

signal neighborspace_updated(cell)

func update_neighborspace():
  var new_neighborspace = [false, false, false, false]
  # check top
  if self.z > 0:
    var top_key = "%d,%d" % [self.x, self.z-1]
    # true if top has a wall
    new_neighborspace[0] = map_grid.lookup_cell(top_key).feature is Building

  if self.x < map_grid.map_size-1:
    var right_key = "%d,%d" % [self.x+1, self.z]
    new_neighborspace[1] = map_grid.lookup_cell(right_key).feature is Building

  if self.z < map_grid.map_size-1:
    var bottom_key = "%d,%d" % [self.x, self.z+1]
    new_neighborspace[2] = map_grid.lookup_cell(bottom_key).feature is Building

  if self.x > 0:
    var left_key = "%d,%d" % [self.x-1, self.z]
    new_neighborspace[3] = map_grid.lookup_cell(left_key).feature is Building

  if new_neighborspace != neighborspace:
    neighborspace = new_neighborspace
    emit_signal("neighborspace_updated", self)
