extends Resource

class_name Pawn

# RPG Stuff
export(String, "Dwarf", "Elf", "Human") var race = "Dwarf" setget set_race
func set_race(new_race):
  race = new_race
  if not stats:
    stats = PawnStats.by_race(race)

export(String) var character_name setget , _get_name
export(Resource) var stats = stats as PawnStats

# Real location on map
export(String) var location = "0,0"
# Derivable from location
var map_cell setget _set_map_cell
var translation = Vector3(0, 0, 0)

# Job Stuff
var on_cooldown := false
var move_speed = 0.4
var build_speed = 100

var key setget , get_key
# Removal
var removed := false

func get_key():
  return character_name

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

class PawnStats:
  extends Resource

  var might
  var will
  var magic

  static func by_race(race):
    var stats = PawnStats.new()

    match race:
      Enums.Race.DWARF:
        stats.might = 1
        stats.will = 1
        stats.magic = -1
      Enums.Race.ELF:
        stats.might = -1
        stats.will = 0
        stats.magic = 2
      Enums.Race.HUMAN:
        stats.might = 0
        stats.will = 2
        stats.magic = 0

    return stats
