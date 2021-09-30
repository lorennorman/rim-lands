extends Spatial

var store setget set_store
func set_store(new_store):
  store = new_store
  share_store_with_children()


func share_store_with_children():
  if store:
    for child in get_children():
      child.store = store
