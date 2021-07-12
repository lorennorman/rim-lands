extends Control

const MapTerrain = preload("res://game/terrain/map_terrain.tscn")

onready var style_control = $TerrainStyle/ItemList
onready var seed_control = $RandomSeed/HSlider
onready var randomize_control = $RandomSeed/Button
onready var height_control = $MountainHeight/SpinBox
onready var scale_control = $NoiseScale/ScaleSpinbox

export(Resource) var map_grid setget set_map_grid
func set_map_grid(new_map_grid):
  if new_map_grid as MapGrid:
    map_grid = new_map_grid

    set_map_grid_on_map_terrain()


func _ready():
  set_map_grid_on_map_terrain()

  # User-alterable settings
  for index in style_control.get_item_count():
    if map_grid.terrain_style == style_control.get_item_text(index):
      style_control.select(index)
      break
  style_control.connect("item_selected", self, "terrain_style_item_selected")

  seed_control.value = map_grid.noise_seed
  seed_control.connect("value_changed", self, "terrain_seed_changed")
  randomize_control.connect("pressed", self, "randomize_terrain_seed")

  # Developer-Specified controls
  height_control.value = map_grid.terrain_height_max
  height_control.connect("value_changed", self, "terrain_height_changed")

  scale_control.value = map_grid.scale_grid_to_noise
  scale_control.connect("value_changed", self, "noise_scale_changed")


func set_map_grid_on_map_terrain():
  var viewport = get_node("./ViewportContainer/Viewport")
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
  set_map_grid_on_map_terrain()


func terrain_height_changed(new_height: int):
  map_grid.maximum_height = new_height
  set_map_grid_on_map_terrain()


func terrain_seed_changed(new_seed: int):
  map_grid.noise_seed = new_seed
  set_map_grid_on_map_terrain()

func randomize_terrain_seed():
  map_grid.noise_seed = RandomNumberGenerator.new().randi_range(-5000,5000)
  set_map_grid_on_map_terrain()

func noise_scale_changed(new_scale: float):
  map_grid.scale_grid_to_noise = new_scale
  set_map_grid_on_map_terrain()
