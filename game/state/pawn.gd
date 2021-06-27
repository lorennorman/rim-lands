extends Resource

class_name Pawn

# RPG Stuff
export(int, -2, 2) var might
export(int, -2, 2) var will
export(int, -2, 2) var magic

export(String, "Dwarf", "Elf", "Human") var race = "Dwarf" setget set_race
func set_race(new_race):
  race = new_race
  if not (might and will and magic):
    default_stats_by_race()

var items = {}

export(String) var character_name setget , _get_name

# Real location on map
export(String) var location = "0,0"
# Derivable from location
var map_cell setget _set_map_cell
var translation = Vector3(0, 0, 0)

# Job Stuff
var on_cooldown := false
var move_speed: float setget , get_move_speed
func get_move_speed():
  return 0.4 + (might/5.0)

var build_speed = 100

var key setget , get_key
# Removal
var removed := false

func get_key():
  return character_name


func _get_name():
  return character_name if character_name else race


var current_job: Job

func is_busy(): return !!current_job

signal updated
signal job_cooldown
func _set_map_cell(cell):
  map_cell = cell
  translation = cell.position
  location = cell.location

  start_job_cooldown(self.move_speed)

func applied_build_speed():
  start_job_cooldown(.5)
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

func default_stats_by_race():
  match race:
    "Dwarf":
      might = 1
      will = 1
      magic = -1
    "Elf":
      might = 1
      will = 1
      magic = 2
    "Human":
      might = 0
      will = 2
      magic = 0

func add_item(item_to_add):
  if not items.has(item_to_add.type):
    items[item_to_add.type] = 0

  items[item_to_add.type] += item_to_add.quantity

func remove_item(item_to_remove):
  assert(items.has(item_to_remove.type), "Pawn was asked to remove an Item it didn't have: %s" % item_to_remove)
  assert(items[item_to_remove.type] >= item_to_remove.quantity, "Pawn was asked to remove more of an item than it had: %s < %s" % [items[item_to_remove.type], item_to_remove.quantity])

  if items[item_to_remove.type] == item_to_remove.quantity:
    items.erase(item_to_remove.type)
  else:
    items[item_to_remove.type] -= item_to_remove.quantity
