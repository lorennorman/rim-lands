extends Spatial

export(NodePath) var quantity_label

var item setget set_item
func set_item(new_item):
  item = new_item
  item_updated(item)

func _ready():
  item.connect("updated", self, "item_updated")

func item_updated(updated_item):
  translation = updated_item.cell.position
  get_node(quantity_label).text = "x%s" % updated_item.quantity
