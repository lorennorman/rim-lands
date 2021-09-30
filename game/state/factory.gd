extends Object

class_name Factory

class Pawns:
  static func default_pawns() -> Array:
    return [
      Pawn.new({
        "character_name": "Brindolf",
        "race": "Dorv",
        "location": "0,0"
      }),
      Pawn.new({
        "character_name": "Conrad",
        "race": "Hum",
        "location": "0,1"
      }),
      Pawn.new({
        "character_name": "S'randra",
        "race": "Alv",
        "location": "1,0"
      }),
    ]
