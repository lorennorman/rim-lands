extends Control

const MapTerrain = preload("res://game/terrain/map_terrain.tscn")

export(NodePath) var viewport_path
export(NodePath) var camera_path
export(NodePath) var style_control_path
export(NodePath) var size_control_path
export(NodePath) var seed_control_path
export(NodePath) var randomize_control_path
export(NodePath) var height_control_path
export(NodePath) var scale_control_path

onready var viewport = get_node(viewport_path)
onready var camera = get_node(camera_path)
onready var style_control = get_node(style_control_path)
onready var size_control = get_node(size_control_path)
onready var seed_control = get_node(seed_control_path)
onready var randomize_control = get_node(randomize_control_path)
onready var height_control = get_node(height_control_path)
onready var scale_control = get_node(scale_control_path)

onready var rng := RandomNumberGenerator.new()

export(Resource) var map_grid setget set_map_grid
func set_map_grid(new_map_grid):
  if new_map_grid as MapGrid:
    map_grid = new_map_grid
    initialize_controls()
    set_map_grid_on_map_terrain()


func _ready():

  # User settings
  style_control.connect("item_selected", self, "terrain_style_item_selected")
  size_control.connect("item_selected", self, "terrain_size_item_selected")
  seed_control.connect("value_changed", self, "terrain_seed_changed")
  randomize_control.connect("pressed", self, "randomize_terrain_seed")

  # Developer-Specified controls
  height_control.connect("value_changed", self, "terrain_height_changed")
  scale_control.connect("value_changed", self, "noise_scale_changed")

  if map_grid:
    initialize_controls()
    set_map_grid_on_map_terrain()

func initialize_controls():
  for index in style_control.get_item_count():
    if map_grid.terrain_style == style_control.get_item_text(index):
      style_control.select(index)
      break
  seed_control.value = map_grid.noise_seed
  height_control.value = map_grid.terrain_height_max
  scale_control.value = map_grid.scale_grid_to_noise

func set_map_grid_on_map_terrain():
  if not viewport: return
  var map_terrain = viewport.get_node_or_null("MapTerrain")

  if not map_terrain:
    map_terrain = MapTerrain.instance()
    viewport.add_child(map_terrain)
    map_terrain.owner = viewport

  map_grid.generate_cells()
  map_terrain.map_grid = map_grid


func terrain_style_item_selected(item_index: int):
  var terrain_style_name = style_control.get_item_text(item_index)
  map_grid.terrain_style = terrain_style_name
  initialize_controls()
  set_map_grid_on_map_terrain()


func terrain_size_item_selected(item_index: int):
  if size_control.is_item_disabled(item_index): return

  var size_name = size_control.get_item_text(item_index)
  var size = 65
  if size_name.find("128") != -1:
    size = 129
  # elif size_name.find("256") != -1:
  #   size = 257
  # elif size_name.find("512") != -1:
  #   size = 513

  camera.translation = Vector3(size/2, camera.translation.y, size/2)
  map_grid.map_size = size
  set_map_grid_on_map_terrain()


func terrain_height_changed(new_height: int):
  map_grid.terrain_height_max = new_height
  set_map_grid_on_map_terrain()


func terrain_seed_changed(new_seed: int):
  map_grid.noise_seed = new_seed
  set_map_grid_on_map_terrain()


func randomize_terrain_seed():
  rng.randomize()
  map_grid.noise_seed = rng.randi_range(-5000,5000)
  seed_control.value = map_grid.noise_seed
  set_map_grid_on_map_terrain()


func noise_scale_changed(new_scale: float):
  map_grid.scale_grid_to_noise = new_scale
  set_map_grid_on_map_terrain()
