extends Resource
class_name Item

signal updated

export(int) var type
export(String) var location
var map_cell: MapCell
var pawn: Pawn
var job: Job

var owner setget set_owner, get_owner
func set_owner(new_owner):
  pawn = null
  job = null
  location = null
  map_cell = null

  if new_owner is Pawn:
    self.pawn = new_owner
  elif new_owner is MapCell:
    self.map_cell = new_owner
  elif new_owner is Job:
    self.job = new_owner
  elif new_owner is String:
    self.location = new_owner
  else:
    printerr("Item given unknown kind of owner: ", new_owner.get_class())

func get_owner():
  if pawn: return pawn
  elif map_cell: return map_cell
  elif job: return job
  elif location: return location

  return null

export(int) var quantity = 1 setget set_quantity
func set_quantity(new_quantity):
  quantity = new_quantity
  emit_signal("updated", self)
  Events.emit_signal("item_updated", self)


var claimant setget set_claimant
func set_claimant(new_claimant) -> void:
  claimant = new_claimant
  Events.emit_signal("item_updated", self)


func _init(mass_assignments: Dictionary = {}):
  Util.mass_assign(self, mass_assignments)


func is_claimed(): return !!claimant


func unclaim(): self.claimant = null


func is_on_map(): return !!self.map_cell
