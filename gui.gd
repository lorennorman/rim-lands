extends Spatial

var hovered_pawn setget set_hovered_pawn
var hovered_feature setget set_hovered_feature
var hovered_terrain setget set_hovered_terrain
var selected_entity
var selected_cell: MapCell
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


func _ready():
  var _node_rclicked = Events.connect("node_rclicked", self, "handle_cell_rclicked")
  var _node_lclicked = Events.connect("node_lclicked", self, "handle_cell_lclicked")
  var _node_hovered = Events.connect("node_hovered", self, "handle_cell_hovered")

func handle_cell_lclicked(cell):
  # new cell clicked
  if selected_cell != cell:
    selected_cell = cell

    $SelectIndicator.translation = selected_cell.position

    # select next entity: pawn, feature, terrain
    selected_entity = selected_cell.pawn
    if not selected_entity:
      selected_entity = selected_cell.feature

    if not selected_entity:
      selected_entity = selected_cell.terrain

  # already-selected cell clicked again
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

func handle_cell_rclicked(cell):
  if selected_entity is Pawn:
    # sim.make_job(Enums.Jobs.MOVE, cell.location, selected_entity)
    pass


var last_hovered_cell
func handle_cell_hovered(cell):
  if cell == last_hovered_cell: return
  assert(cell, "Invalid cell passed to handle_cell_hovered: %s" % cell)

  last_hovered_cell = cell
  self.hovered_pawn = cell.pawn
  self.hovered_feature = cell.feature
  self.hovered_terrain = cell.terrain

  $HoverIndicator.translation = cell.position
