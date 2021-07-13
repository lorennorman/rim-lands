extends Button

func _ready():
  connect("pressed", self, "menu_clicked")

func menu_clicked():
  Events.emit_signal("menu_pressed")
