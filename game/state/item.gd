extends Resource

class_name Item

signal updated

export(Enums.Items) var type
export(String) var location
var cell: MapCell
var quantity: int = 1
