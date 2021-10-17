tool
extends Spatial

export(String, "Dorv", "Alv", "Hum") var presenting_race = "Dorv"

var character_name setget _set_character_name, _get_character_name

var pawn setget _set_pawn

func _ready():
  if not pawn:
    var new_pawn = Pawn.new()
    new_pawn.race = presenting_race
    self.pawn = new_pawn

  pawn.connect("updated", self, "model_did_update")

func model_did_update(new_pawn):
  if presenting_race != pawn.race:
    present_as(pawn.race)

  if self.translation != pawn.translation:
    if $Tween.is_active():
      $Tween.stop(self, "translation")
      $Tween.remove(self, "translation")

    $Tween.interpolate_property(self, "translation",
      self.translation, pawn.translation, pawn.move_speed*0.995,
      Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $Tween.start()

func present_as(race):
  presenting_race = race
  $Dorv.visible = false
  $Alv.visible = false
  $Hum.visible = false

  get_node(race).visible = true

func _set_race(new_race):
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
