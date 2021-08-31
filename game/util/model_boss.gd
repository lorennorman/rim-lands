extends Spatial
class_name ModelBoss

export(bool) var bind_to_global_signals = true
export(PackedScene) var scene_to_instance
export(String) var resource_name
export(String) var key_method = "to_string"
export(String) var filter_method

var scenes = {}

func _ready():
  if bind_to_global_signals:
    var resource_collection_added = "%s_collection_added" % resource_name
    var resource_added = "%s_added" % resource_name
    var resource_removed = "%s_removed" % resource_name
    Events.connect(resource_collection_added, self, "add_collection_of_scenes")
    Events.connect(resource_added, self, "add_scene")
    Events.connect(resource_removed, self, "remove_scene")
    Events.connect("game_state_teardown", self, "teardown")


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
  add_child(scene)
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
