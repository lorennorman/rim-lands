extends Resource

class_name Building

var type
export(String) var location
var map_cell

var key setget , get_key
func get_key():
  return location

var name setget , get_name
func get_name():
  return "Wall"

func _init(mass_assignments: Dictionary = {}):
  Util.mass_assign(self, mass_assignments)
