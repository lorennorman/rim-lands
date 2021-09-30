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
  store = new_store
  if store: subscribe_to_store()
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
  if store.has_method(collection_getter_name()):
    add_collection_of_scenes(store.call(collection_getter_name()))


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
