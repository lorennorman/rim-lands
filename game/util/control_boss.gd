extends Control
class_name ControlBoss

export(NodePath) var boss_container_path
onready var boss_container = get_node(boss_container_path)

export(PackedScene) var scene_to_instance
export(String) var resource_name
export(String) var key_method = "to_string"
export(String) var filter_method


# resources are truth
# - observe them
# - sort/id/diff them by their keys
# - scenes attach to them
var resources = []
var scenes = {}

var store setget set_store
func set_store(new_store):
  if store: printerr("ControlBoss error: my store is already set and its not made to be set twice")

  # mutate
  store = new_store

  # pass a generator function to the store's reactor
  store.register_reactive_function(self, "generate_controls")


# reactive function: use the store and it'll call you again whenever the things
# you used change. be smart! only do work if something actually changed.
func generate_controls(game_store):
  # accessing the getters automatically registers listeners for
  # changes to those getters, automatically calling this function again
  var resource_collection = game_store.getters("%ss" % resource_name)
  # print(resource_collection)
  if !resource_collection: resource_collection = []

  # remove all current scenes not present in new scenes (current - new)
  for existing_resource in resources:
    if resource_collection.find(existing_resource) == -1:
      remove_resource(existing_resource)

  # add all scenes not present in current scenes (new - current)
  for new_resource in resource_collection:
    if resources.find(new_resource) == -1:
      add_resources([new_resource])


func collection_getter_name(): return "get_%ss" % resource_name


func get_key(resource):
  # FIXME: couldn't call Dictionary#hash dynamically for some reason?
  if resource is Dictionary and key_method == "hash": return resource.hash()
  return resource.call(key_method)


func filtered(resource) -> bool:
  if filter_method: return not resource.call(filter_method)
  else: return false


func add_resources(new_resources):
  resources.append_array(new_resources)

  for resource in new_resources:
    add_scene(resource)


func remove_resource(stale_resource):
  resources.erase(stale_resource)

  remove_scene(stale_resource)


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
