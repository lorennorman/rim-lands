extends Resource

var type setget _type
var location setget _location
var area setget _area
var current_worker setget _current_worker
var percent_complete = 0

signal updated(job)

func _type(new_type):
  type = new_type
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

func complete():
  if current_worker and current_worker.current_job == self:
    current_worker.current_job = null
  emit_signal("updated", self)
  Events.emit_signal("job_completed", self)

func is_claimed():
  return current_worker

func as_text():
  var claim_status = "x" if is_claimed() else " "
  var owner = current_worker.character_name if current_worker else ""
  var text

  match type:
    Enums.Jobs.MOVE:
      text = "Move to:"
    Enums.Jobs.BUILD:
      text = "Build at:"

  return "[%s] %s @ %s -%s" % [claim_status, text, location, owner]
