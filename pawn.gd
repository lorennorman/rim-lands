class_name Pawn

var translation = Vector3(0, 0, 0)
var race = "Dwarf"

var character_name setget , _get_name

func _get_name():
  return character_name if character_name else race

var current_job

func is_busy():
  return current_job
