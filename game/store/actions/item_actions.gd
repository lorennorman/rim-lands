extends Object


func action_add_item(store, payload):
  var item = Item.new(payload)
  store.game_state.items.push_back(item)
  StateActivator.activate_item(item, store.map)
  store.emit_signal("item_added", item)


func action_destroy_item(store, item):
  store.game_state.items.erase(item)
  StateActivator.deactivate_item(item)
  store.emit_signal("item_removed", item)


func action_transfer_item(store, payload):
  # unpack payload
  var item_type: int = payload["type"]
  var item_quantity: int = payload["quantity"]
  var from: Resource = payload["from"]
  var to: Resource = payload["to"]

  # check that "from" has enough of this item
  var from_item = from.get_item(item_type)
  assert(from_item, "Attempted to transfer an item the source doesn't have: %s" % item_type)
  assert(from_item.quantity >= item_quantity, "Attempted to transfer more of an item than the source has: %s < %s" % [from_item.quantity, item_quantity])
  from_item.quantity -= item_quantity
  if from_item.quantity <= 0: store.action("destroy_item", from_item)

  # check if "to" already has some of this item
  var to_item = to.get_item(item_type)
  if to_item:
    # shuffle quantities
    to_item.quantity += item_quantity

  else:
    # build from scratch
    var item_properties = {
      "type": item_type,
      "quantity": item_quantity,
      "owner": to
    }
    store.action("add_item", item_properties)
