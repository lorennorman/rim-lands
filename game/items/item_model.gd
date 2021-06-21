extends Spatial

var item setget set_item
func set_item(new_item):
  item = new_item
  item_updated(item)

func _ready():
  item.connect("updated", self, "item_updated")

func item_updated(updated_item):
  translation = updated_item.cell.position
