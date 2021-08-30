extends Resource
class_name PawnTemplate

export(String) var name = ""
export(bool) var use_random_name = false

export(String, "Hum", "Dorv", "Alv", "Erk") var race
export(bool) var use_random_race = false

export(String) var location
export(bool) var use_random_location = false
