extends CanvasLayer

var hovered_pawn setget set_hovered_pawn
var hovered_feature setget set_hovered_feature
var hovered_terrain setget set_hovered_terrain
var selected_entity setget set_selected_entity

func set_hovered_pawn(pawn):
  var name = pawn.character_name if pawn else ""
  
  $Left/VSplitContainer/VBoxContainer/PawnHoverLabel.text = "Pawn: %s" % name
  

func set_hovered_feature(feature):
  var name = feature.name if feature else ""
  
  $Left/VSplitContainer/VBoxContainer/FeatureHoverLabel.text = "Feature: %s" % name

func set_hovered_terrain(terrain):
  var color = terrain if terrain else Color(0)
  
  $Left/VSplitContainer/VBoxContainer/TerrainHoverLabel/ColorRect.color = color

func set_selected_entity(entity):
  $Left/VSplitContainer/Panel/MarginContainer/TargetFocus.text = "%s" % entity

## Jobs

var JobLabel = preload("res://job_label.gd")

func add_job(job):
  $Right/VSplitContainer/Jobs/JobsList.add_child(JobLabel.new(job))
