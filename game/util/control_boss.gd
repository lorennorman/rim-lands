extends Control
class_name ControlBoss

export(NodePath) var boss_container_path
onready var boss_container = get_node(boss_container_path)

export(PackedScene) var scene_to_instance
export(String) var resource_name
export(String) var key_method = "to_string"
export(String) var filter_method

var store setget set_store
func set_store(new_store):
  if store: printerr("ControlBoss error: my store is already set and its not made to be set twice")
  #
  # if store == new_store:
  #   printerr('set_store: new store == old store')
  #   return

  # unsubscribe
  # if store: unsubscribe_from_store()

  # unhook the generator function
  # store.unregister_reactive_function(self, "generate_controls")

  # mutate
  store = new_store

  # subscribe
  # if store: subscribe_to_store()

  # pass a generator function
  store.register_reactive_function(self, "generate_controls")


# let the magic begin
func generate_controls(game_store):
  print(self, " got called with: ", game_store, " for ", resource_name)
  # accessing the getters automatically registers listeners for
  # changes to those getters, automatically calling this function again
  var resources = game_store.getters("%ss" % resource_name)
  print(resources)
  if !resources: resources = []
  # brute force method: annihilate all then add all
  teardown()
  add_collection_of_scenes(resources)

  # TODO: optimized method
  # remove all current scenes not present in new scenes (current - new)
  # add all scenes not present in current scenes (new - current)


var scenes = {}


func collection_getter_name(): return "get_%ss" % resource_name


func subscribe_to_store():
  var resource_collection_added = "%s_collection_added" % resource_name
  var resource_added = "%s_added" % resource_name
  var resource_removed = "%s_removed" % resource_name
  store.connect(resource_collection_added, self, "add_collection_of_scenes")
  store.connect(resource_added, self, "add_scene")
  store.connect(resource_removed, self, "remove_scene")
  store.connect("game_state_teardown", self, "teardown")

  # wow already metaprogramming
  # TODO: let's hoist this idea up into a proper Util and make it safer, self-documenting
  if store.has_method(collection_getter_name()):
    add_collection_of_scenes(store.call(collection_getter_name()))

  # TODO: expose a way to call a property?
  # if store.has(collection_property_name()):
  #   add_collection_of_scenes(store.get(collection_property_name()))


func get_key(resource):
  # FIXME: couldn't call Dictionary#hash dynamically for some reason?
  if resource is Dictionary and key_method == "hash": return resource.hash()
  return resource.call(key_method)


func filtered(resource) -> bool:
  if filter_method: return not resource.call(filter_method)
  else: return false


func add_collection_of_scenes(resources):
  for resource in resources:
    add_scene(resource)


func after_added(_resource, _scene): pass
func add_scene(resource) -> void:
  if filtered(resource): return
  var scene = scene_to_instance.instance()
  scene[resource_name] = resource
  scenes[get_key(resource)] = scene
  boss_container.add_child(scene)
  after_added(resource, scene)


func after_removed(_resource): pass
func remove_scene(resource) -> void:
  if filtered(resource): return
  var scene = scenes[get_key(resource)]
  scenes.erase(get_key(resource))
  scene.queue_free()
  after_removed(resource)


func teardown():
  for scene in scenes.values(): scene.queue_free()
  scenes.clear()
