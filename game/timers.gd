# Simply expose timer functionality globally so that non-scene-tree files
# can use timer yield()s
extends Spatial

func _ready():
  Events.connect("start_timer", self, "handle_start_timer")

func handle_start_timer(timer):
  # Thank you for the timer, we'll throw it on the scene tree until it goes off
  add_child(timer)
  # -- make sure you (the caller) listen for this too! --
  yield(timer, "timeout")
  # ...then clean it up once it goes off
  remove_child(timer)
