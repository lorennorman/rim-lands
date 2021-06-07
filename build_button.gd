# Lots of interactivity with the Build job:
# - build which building?
# - in which material?
# - categories, filtering/sorting options
# - tech tree forward visibility
# - recently used quickbar
extends MenuButton

const button_map = {
  0: Enums.Buildings.WALL,
  1: Enums.Buildings.DOOR
}

func _ready():
  var popup = get_popup()
  popup.connect("id_pressed", self, "file_menu")

func file_menu( id ):
  var building = button_map[id]

  Events.emit_signal("set_mode", { "mode": Enums.Jobs.BUILD, "building": building })