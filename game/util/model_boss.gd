extends Spatial

export(PackedScene) var scene_to_instance
export(String) var resource_to_observe
export(String) var key_method = "to_string"

var scenes = {}

func _ready():
  var resource_added = "%s_added" % resource_to_observe
  var resource_removed = "%s_removed" % resource_to_observe
  Events.connect(resource_added, self, "add_scene")
  Events.connect(resource_removed, self, "remove_scene")
  Events.connect("game_state_teardown", self, "teardown")


func get_key(resource):
  return funcref(resource, key_method).call_func()


func add_scene(resource) -> void:
  var scene = scene_to_instance.instance()
  scene[resource_to_observe] = resource
  scenes[get_key(resource)] = scene
  add_child(scene)


func remove_scene(resource) -> void:
  var scene = scenes[get_key(resource)]
  scenes.erase(get_key(resource))
  scene.queue_free()


func teardown():
  for scene in scenes.values(): scene.queue_free()
  scenes.clear()
