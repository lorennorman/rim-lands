extends Spatial

var hovered_pawn setget set_hovered_pawn
var hovered_feature setget set_hovered_feature
var hovered_terrain setget set_hovered_terrain

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
  var _hcu = Events.connect("hovered_cell_updated", self, "hovered_cell_updated")
  var _scu = Events.connect("selected_cell_updated", self, "selected_cell_updated")
  var _seu = Events.connect("selected_entity_updated", self, "selected_entity_updated")

func hovered_cell_updated(cell):
  self.hovered_pawn = cell.pawn
  self.hovered_feature = cell.feature
  self.hovered_terrain = cell.terrain

  $HoverIndicator.translation = cell.position

func selected_entity_updated(entity):
  if entity is Pawn:
    $Menus/Left/VSplitContainer/Panel/MarginContainer/TargetFocus.text = "%s" % entity.character_name
  else:
    $Menus/Left/VSplitContainer/Panel/MarginContainer/TargetFocus.text = "%s" % entity

func selected_cell_updated(cell):
  $SelectIndicator.translation = cell.position
