extends Resource
class_name Job

# Job canceled or deleted
var removed := false
var sub_jobs = []

signal updated(job)

export(Enums.Jobs) var job_type setget set_job_type
func set_job_type(new_job_type):
  job_type = new_job_type
  emit_signal("updated", self)

export(String) var location setget set_location
func set_location(new_location):
  location = new_location
  emit_signal("updated", self)

var params setget set_params
func set_params(_new_params):
  pass

var area setget set_area
func set_area(new_area):
  area = new_area
  emit_signal("updated", self)

var map_cell setget set_map_cell
func set_map_cell(new_map_cell):
  map_cell = new_map_cell
  location = map_cell.location

var key setget , get_key
func get_key(): return "%s:%s" % [job_type, location]

var current_worker setget set_current_worker
func set_current_worker(new_worker):
  current_worker = new_worker
  emit_signal("updated", self)

export(int, 0, 100) var percent_complete = 0 setget set_percent_complete
func set_percent_complete(new_percent_complete):
  percent_complete = new_percent_complete
  emit_signal("updated", self)

### CONSTRUCTOR ###
func _init(mass_assignments: Dictionary = {}):
  Util.mass_assign(self, mass_assignments)


### METHODS ###
func can_be_completed():
  return true

func is_claimed():
  return current_worker

func complete():
  if current_worker and current_worker.current_job == self:
    current_worker.current_job = null
  emit_signal("updated", self)
  Events.emit_signal("job_completed", self)


func as_text():
  var claim_status = "x" if is_claimed() else " "
  var owner = current_worker.character_name if current_worker else ""
  var text

  match job_type:
    Enums.Jobs.MOVE:
      text = "Move to:"
    Enums.Jobs.BUILD:
      text = "Build at:"
    Enums.Jobs.HAUL:
      text = "Haul to:"

  return "[%s] %s @ %s -%s" % [claim_status, text, location, owner]
