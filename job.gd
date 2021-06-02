extends Resource

class_name Job

export(Enums.Jobs) var job_type setget _job_type
export(String) var location setget _location
var area setget _area
var map_cell
var key setget , get_key
var current_worker setget _current_worker
export(int, 0, 100) var percent_complete = 0 setget _percent_complete

# Job canceled or deleted
var removed := false

signal updated(job)

func get_key():
  return "%s:%s" % [job_type, location]

func _job_type(new_job_type):
  job_type = new_job_type
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

func _percent_complete(new_percent_complete):
  percent_complete = new_percent_complete
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

  match job_type:
    Enums.Jobs.MOVE:
      text = "Move to:"
    Enums.Jobs.BUILD:
      text = "Build at:"

  return "[%s] %s @ %s -%s" % [claim_status, text, location, owner]
