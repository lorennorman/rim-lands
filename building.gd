extends Resource

class_name Building

var type
var location
var map_cell

var key setget , get_key
func get_key():
  return location

var name setget , get_name
func get_name():
  return "Wall"
