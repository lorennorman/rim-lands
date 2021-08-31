tool
extends Control

export(Resource) var pawn: Resource setget set_pawn
func set_pawn(new_pawn: Pawn):
  pawn = new_pawn
  $Name.text = pawn.character_name
  $Race.text = pawn.race
  $Stats.text = pawn.location
