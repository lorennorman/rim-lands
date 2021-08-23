extends Object

class_name Factory

class Pawns:
  static func default_pawns() -> Array:
    return [
      Pawn.new({
        "character_name": "Brindolf",
        "race": "Dwarf",
        "location": "0,0"
      }),
      Pawn.new({
        "character_name": "Conrad",
        "race": "Human",
        "location": "0,1"
      }),
      Pawn.new({
        "character_name": "S'randra",
        "race": "Elf",
        "location": "1,0"
      }),
    ]
