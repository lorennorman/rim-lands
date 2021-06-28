extends Resource

class_name MapCell

signal pathing_updated(astar_id, pathable)

var map_grid

var position: Vector3
var disabled: bool
var astar_id: int
var location: String
var x setget , get_x
func get_x(): return position.x-0.5
var z setget , get_z
func get_z(): return position.z-0.5

var pawn: Pawn setget set_pawn
func set_pawn(new_pawn):
  pawn = new_pawn
  update_pathing()

var feature setget set_feature
func set_feature(new_feature):
  feature = new_feature
  update_pathing()

var terrain

func update_pathing():
  emit_signal("pathing_updated", astar_id, (!pawn and feature != Building))

func can_take_job(job_to_take):
  if job_to_take.job_type == Enums.Jobs.BUILD:
    return !feature

  return true

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
