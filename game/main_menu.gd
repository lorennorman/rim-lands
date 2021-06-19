extends WindowDialog

func _ready():
  Events.connect("menu_pressed", self, "popup")
  $MarginContainer/HBoxContainer/NewButton.connect("pressed", self, "new_clicked")
  $MarginContainer/HBoxContainer/LoadButton.connect("pressed", self, "load_clicked")
  $MarginContainer/HBoxContainer/SaveButton.connect("pressed", self, "save_clicked")

func new_clicked():
  visible = false
  Events.emit_signal("new_world_requested")

func load_clicked():
  visible = false
  $LoadDialog.popup()
  # Events.emit_signal("load_world_requested")

func save_clicked():
  visible = false
  $SaveDialog.popup()
  # Events.emit_signal("save_world_requested")
