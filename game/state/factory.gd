extends Object

class_name Factory

class Pawns:
  static func default_pawns() -> Array:
    return [
      Pawn.new({
        "character_name": "Brindolf",
        "race": "Dwarf"
      }),
      Pawn.new({
        "character_name": "Conrad",
        "race": "Human"
      }),
      Pawn.new({
        "character_name": "S'randra",
        "race": "Elf"
      }),
    ]
