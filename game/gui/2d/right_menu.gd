extends MarginContainer

export(NodePath) var job_label_boss_path
onready var job_label_boss = get_node(job_label_boss_path)

var store setget set_store
func set_store(new_store):
  job_label_boss.store = new_store
