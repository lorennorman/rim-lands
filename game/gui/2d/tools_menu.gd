# Lots of interactivity with the Build job:
# - build which building?
# - in which material?
# - categories, filtering/sorting options
# - tech tree forward visibility
# - recently used quickbar
extends GridContainer

const building_button_map = {
  0: Enums.Buildings.WALL,
  1: Enums.Buildings.DOOR
}


func _ready():
  var build_popup = $Build.get_popup()
  build_popup.connect("id_pressed", self, "building_menu_selected")


func building_menu_selected(id):
  var building = building_button_map[id]
  Events.emit_signal("set_mode", { "mode": Enums.Mode.BUILD, "building": building })


func chop_pressed():
  Events.emit_signal("set_mode", { "mode": Enums.Mode.CHOP })


func sow_pressed():
  Events.emit_signal("set_mode", { "mode": Enums.Mode.SOW })


func reap_pressed():
  Events.emit_signal("set_mode", { "mode": Enums.Mode.REAP })


func mine_pressed():
  Events.emit_signal("set_mode", { "mode": Enums.Mode.MINE })


func forge_pressed():
  Events.emit_signal("set_mode", { "mode": Enums.Mode.FORGE })


func forage_pressed():
  Events.emit_signal("set_mode", { "mode": Enums.Mode.FORAGE })
