extends Resource

class_name Pawn

var map_cell setget _set_map_cell
var location = "0,0"
var translation = Vector3(0, 0, 0)
var race = "Dwarf"
var character_name setget , _get_name

# Job Stuff
var on_cooldown := false
var move_speed = 0.4
var build_speed = 20

func _get_name():
  return character_name if character_name else race

var current_job setget _set_job

func is_busy():
  return current_job

func _set_job(job):
  current_job = job

signal updated
signal job_cooldown
func _set_map_cell(cell):
  map_cell = cell
  translation = cell.position
  location = cell.location

  start_job_cooldown(move_speed)

func applied_build_speed():
  start_job_cooldown(1.5)
  return build_speed

func start_job_cooldown(time):
  # Job Cooldown
  on_cooldown = true
  self.emit_signal("updated")
  var job_timer = Timer.new()
  job_timer.wait_time = time
  job_timer.autostart = true
  job_timer.one_shot = true
  Events.emit_signal("start_timer", job_timer)

  yield(job_timer, "timeout")
  on_cooldown = false
  self.emit_signal("job_cooldown")
