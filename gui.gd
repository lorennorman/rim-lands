extends Spatial

var hovered_pawn setget set_hovered_pawn
var hovered_feature setget set_hovered_feature
var hovered_terrain setget set_hovered_terrain
var selected_entity# setget set_selected_entity
var selected_location_key
var selected_cell
var game_state: GameState

func set_hovered_pawn(pawn):
  var name = pawn.character_name if pawn else ""
  $Menus/Left/VSplitContainer/VBoxContainer/PawnHoverLabel.text = "Pawn: %s" % name


func set_hovered_feature(feature):
  var name = feature.name if feature else ""
  $Menus/Left/VSplitContainer/VBoxContainer/FeatureHoverLabel.text = "Feature: %s" % name


func set_hovered_terrain(terrain):
  var color = terrain if terrain else Color(0)
  $Menus/Left/VSplitContainer/VBoxContainer/TerrainHoverLabel/ColorRect.color = color


## Jobs
var JobLabel = preload("res://job_label.gd")

func add_job(job):
  $Menus/Right/VBox/Jobs/JobsList.add_child(JobLabel.new(job))

func _ready():
  var _node_rclicked = Events.connect("node_rclicked", self, "handle_cell_rclicked")
  var _node_lclicked = Events.connect("node_lclicked", self, "handle_cell_lclicked")
  var _node_hovered = Events.connect("node_hovered", self, "handle_cell_hovered")
  var _job_added = Events.connect("job_added", self, "add_job")

func handle_cell_lclicked(location_key):
  if selected_location_key != location_key:
    selected_location_key = location_key

    selected_cell = game_state.map_grid.lookup_cell(location_key)
    $SelectIndicator.translation = selected_cell.position

    # select next entity: pawn, feature, terrain
    selected_entity = selected_cell.pawn
    if not selected_entity:
      selected_entity = selected_cell.feature

    if not selected_entity:
      selected_entity = selected_cell.terrain

  else:
    if selected_entity is Color:
      return

    if selected_entity == selected_cell.pawn and selected_cell.feature:
      selected_entity = selected_cell.feature
    else:
      selected_entity = selected_cell.terrain

  if selected_entity is Pawn:
    $Menus/Left/VSplitContainer/Panel/MarginContainer/TargetFocus.text = "%s" % selected_entity.character_name
  else:
    $Menus/Left/VSplitContainer/Panel/MarginContainer/TargetFocus.text = "%s" % selected_entity

func handle_cell_rclicked(location_key):
  if selected_entity is Pawn:
    # sim.make_job(Enums.Jobs.MOVE, location_key, selected_entity)
    pass


var last_hovered
func handle_cell_hovered(location_key):
  if location_key == last_hovered: return

  last_hovered = location_key
  var cell = game_state.map_grid.lookup_cell(location_key)
  if cell:
    self.hovered_pawn = cell.pawn
    self.hovered_feature = cell.feature
    self.hovered_terrain = cell.terrain

    $HoverIndicator.translation = cell.position
