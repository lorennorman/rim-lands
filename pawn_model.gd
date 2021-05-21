tool
extends Spatial

#var Pawn = load("Pawn.gd")

export(String, "Dwarf", "Elf", "Human") var presenting_race = "Dwarf"

var character_name setget _set_character_name, _get_character_name

var pawn setget _set_pawn

func _ready():
  if not pawn:
    pawn = Pawn.new()
    pawn.race = presenting_race

  present_as(pawn.race)

func present_as(race):
  $Dwarf.visible = false
  $Elf.visible = false
  $Human.visible = false

  get_node(race).visible = true

func _set_race(new_race):
  print("setting race: %s" % new_race)
  if pawn:
    pawn.race = new_race

func _get_race():
  if pawn:
    return pawn.race

func _set_character_name(new_name):
  if pawn:
    pawn.character_name = new_name

func _get_character_name():
  if pawn:
    return pawn.character_name

func _set_pawn(new_pawn):
  pawn = new_pawn
  
  translation = pawn.translation
  present_as(pawn.race)
