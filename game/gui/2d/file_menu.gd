extends VBoxContainer

func _ready():
  $FileMenu/NewButton.connect("pressed", self, "new_clicked")
  $FileMenu/LoadButton.connect("pressed", self, "load_clicked")
  $FileMenu/SaveButton.connect("pressed", self, "save_clicked")

func new_clicked():
  Events.emit_signal("new_world_requested")

func load_clicked():
  Events.emit_signal("load_world_requested")

func save_clicked():
  Events.emit_signal("save_world_requested")
