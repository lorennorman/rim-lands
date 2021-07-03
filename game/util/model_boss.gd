extends Spatial

class_name ModelBoss

export(PackedScene) var scene_to_instance
export(String) var resource_to_observe
export(String) var key_method = "to_string"
export(String) var filter_method

var scenes = {}

func _ready():
  var resource_added = "%s_added" % resource_to_observe
  var resource_removed = "%s_removed" % resource_to_observe
  Events.connect(resource_added, self, "add_scene")
  Events.connect(resource_removed, self, "remove_scene")
  Events.connect("game_state_teardown", self, "teardown")


func get_key(resource):
  return resource.call(key_method)


func filtered(resource) -> bool:
  if filter_method: return not resource.call(filter_method)
  else: return false


func after_added(_resource, _scene): pass
func add_scene(resource) -> void:
  if filtered(resource): return
  var scene = scene_to_instance.instance()
  scene[resource_to_observe] = resource
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
