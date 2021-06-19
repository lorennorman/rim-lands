extends VBoxContainer

func _ready():
  $FileMenu/MenuButton.connect("pressed", self, "menu_clicked")

func menu_clicked():
  Events.emit_signal("menu_pressed")
