tool
extends Control


export(Resource) var pawn: Resource setget set_pawn
func set_pawn(new_pawn: Pawn):
  pawn = new_pawn
  $Reroll.visible = true
  $Name.text = pawn.character_name
  $Race.text = pawn.race
  $Stats.text = pawn.location


func reroll_pressed():
  if pawn:
    print("Rerolling %s..." % pawn.character_name)
