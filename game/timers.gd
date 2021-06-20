# Simply expose timer functionality globally so that non-scene-tree files
# can use timer yield()s
extends Spatial

var timers = []
var clearing = false

func _ready():
  Events.connect("start_timer", self, "start_timer")
  Events.connect("game_state_teardown", self, "game_state_teardown")

func start_timer(timer):
  # Thank you for the timer, we'll throw it on the scene tree until it goes off
  add_child(timer)
  timers.push_back(timer)
  # -- make sure you (the caller) listen for this too! --
  yield(timer, "timeout")
  # ...then clean it up once it goes off

  timers.erase(timer)
  timer.queue_free()

func game_state_teardown():
  # ignore all timers
  for timer in timers:
    timer.stop()
    timer.queue_free()

  timers.clear()
  clearing = true
