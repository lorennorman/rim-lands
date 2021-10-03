extends Object

func action_buildup_forest(store, forest):
  StateActivator.activate_forest(forest, store.map)


func action_destroy_forest(store, forest_dict):
  var found_forest

  for forest in store.forests:
    if forest.x == forest_dict.x and forest.z == forest_dict.z:
      found_forest = forest
      break

  assert(found_forest, "No forest found for: %s" % forest_dict)

  store.forests.erase(found_forest)
  store.emit_signal("forest_removed", found_forest)
