extends Resource
class_name MapTemplate

export(String, "core", "rim", "void") var environment

export(Enums.MapSizes) var map_size

export(int) var terrain_seed
export(bool) var use_random_terrain_seed = false

# Per-environment options
export(int) var forest_seed
export(bool) var use_random_forest_seed = false
export(int) var oasis_seed
