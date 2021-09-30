extends Object

class_name Enums

# GUI
const Mode = {
  SELECT = "Select",
  BUILD = "Build",
  CHOP = "Chop",
  MINE = "Mine",
  FORGE = "Forge",
  SOW = "Sow",
  REAP = "Reap",
  FORAGE = "Forage"
}

# MAPS
const Environments = {
  CORE = "Core's Edge",
  RIM = "The Rim Eternal",
  VOID = "The Voidlands",
}

enum MapSizes { SMALL=65, MEDIUM=129 }

# PAWNS
enum Race { DWARF, ELF, HUMAN, ORC, VOIDBORN }
enum Stats { MIGHT, WILL, MAGIC }

# JOBS
const Jobs = {
  MOVE = "Move",
  BUILD = "Build",
  HAUL = "Haul",
  CHOP = "Chop",
  FORAGE = "Forage",
  SOW = "Sow",
  REAP = "Reap",
  CULTIVATE = "Cultivate",
  MINE = "Mine",
  FORGE = "Forge"
}

# BUILDINGS
enum Buildings { WALL, DOOR }

# ITEMS
enum Items { LUMBER }
