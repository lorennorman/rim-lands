extends Resource
class_name Item

signal updated

export(int) var type
export(String) var location
var map_cell: MapCell
var quantity: int = 1 setget set_quantity
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
