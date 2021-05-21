extends Resource

var name setget _name
var location setget _location
var area setget _area
var current_worker setget _current_worker

signal updated(job)

func _name(new_name):
  name = new_name
  emit_signal("updated", self)

func _location(new_location):
  location = new_location
  emit_signal("updated", self)

func _area(new_area):
  area = new_area
  emit_signal("updated", self)

func _current_worker(new_worker):
  current_worker = new_worker
  emit_signal("updated", self)

func is_claimed():
  return current_worker
