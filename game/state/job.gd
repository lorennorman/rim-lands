extends Resource
class_name Job

# Will be set if this is a sub-job
var parent: Job

# Job canceled or deleted
var removed := false
var sub_jobs = []

signal updated(job)
signal completed(job)

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
func get_key(): return to_string() #"%s:%s" % [job_type, location]


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
  return completable


var completable_signals = []
var completable = true
func uncompletable_until(signals_to_watch):
  completable = false
  clear_completable_signals()
  completable_signals = signals_to_watch
  for watch_signal in signals_to_watch:
    Events.connect(watch_signal, self, "set_completable")


func set_completable(_args):
  completable = true
  clear_completable_signals()


func clear_completable_signals():
  for watch_signal in completable_signals:
    Events.disconnect(watch_signal, self, "set_completable")
  completable_signals.clear()


func is_claimed():
  return current_worker


func complete():
  # clear your worker
  if current_worker and current_worker.current_job == self:
    current_worker.current_job = null
  # clear your cell
  if map_cell and map_cell.feature == self:
    map_cell.feature = null

  emit_signal("updated", self)
  emit_signal("completed", self)
  Events.emit_signal("job_completed", self)


func sub_job_completed(sub_job):
  sub_jobs.erase(sub_job)


func as_text():
  var claim_status = "x" if is_claimed() else " "
  var owner = current_worker.character_name if current_worker else ""
  var text = "%s at:" % job_type

  if job_type == Enums.Jobs.MOVE: text = "Move to:"

  return "[%s] %s @ %s -%s" % [claim_status, text, location, owner]


func uses_job_boss():
  # no build jobs, no sub jobs
  return not job_type == Enums.Jobs.BUILD and not parent
