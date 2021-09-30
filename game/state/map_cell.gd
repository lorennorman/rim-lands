extends Resource

class_name MapCell

signal pathing_updated(astar_id, pathable)

var map

var position: Vector3
var disabled: bool = false
var astar_id: int
var location: String
var x setget , get_x
func get_x(): return position.x-0.5
var z setget , get_z
func get_z(): return position.z-0.5

var pawn setget set_pawn
func set_pawn(new_pawn):
  pawn = new_pawn
  update_pathing()

var feature setget set_feature
func set_feature(new_feature):
  feature = new_feature
  update_pathing()

var terrain

func update_pathing():
  # no pawns or buildings
  var navigable = not pawn and not (feature is Building)
  emit_signal("pathing_updated", astar_id, navigable)

func can_take_job(job_to_take):
  if job_to_take.job_type == Enums.Jobs.BUILD and feature is Job:
      if feature != job_to_take.parent:
        return false

  return true

var neighborspace = [false, false, false, false]

signal neighborspace_updated(cell)

func update_neighborspace():
  var new_neighborspace = [false, false, false, false]
  # check top
  if self.z > 0:
    var top_key = "%d,%d" % [self.x, self.z-1]
    # true if top has a wall
    new_neighborspace[0] = map.lookup_cell(top_key).feature is Building

  if self.x < map.size-1:
    var right_key = "%d,%d" % [self.x+1, self.z]
    new_neighborspace[1] = map.lookup_cell(right_key).feature is Building

  if self.z < map.size-1:
    var bottom_key = "%d,%d" % [self.x, self.z+1]
    new_neighborspace[2] = map.lookup_cell(bottom_key).feature is Building

  if self.x > 0:
    var left_key = "%d,%d" % [self.x-1, self.z]
    new_neighborspace[3] = map.lookup_cell(left_key).feature is Building

  if new_neighborspace != neighborspace:
    neighborspace = new_neighborspace
    emit_signal("neighborspace_updated", self)


# Inventory Interface
var feature_is_item := false
func has_item(item_type: int) -> bool:
  return feature_is_item and feature.type == item_type


func get_item(item_type: int):
  if feature_is_item and feature.type == item_type:
    return feature
  else: return null


func remove_item(item):
  assert(feature == item, "MapCell asked to remove item it didn't have.")
  feature = null
  feature_is_item = false
