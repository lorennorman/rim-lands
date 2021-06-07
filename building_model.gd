extends Spatial

const None = preload("res://buildings/walls/none.tscn")
const One = preload("res://buildings/walls/1_adjacent.tscn")
const TwoAcross = preload("res://buildings/walls/2_across.tscn")
const TwoAngle = preload("res://buildings/walls/2_angle.tscn")
const Three = preload("res://buildings/walls/3_perpendicular.tscn")
const Four = preload("res://buildings/walls/4_way.tscn")

var cell: MapCell
var model: Spatial

func _ready():
  assert(cell, "BuildingModel became _ready() without a Cell")
  var _nu = cell.connect("neighborspace_updated", self, "neighborspace_updated")
  cell.update_neighborspace()

func neighborspace_updated(_cell):
  # get the existing model, remove it
  if model:
    remove_child(model)
    model.queue_free()

  # determine the appropriate model, add it
  model = building_model_from_neighborspace(cell.neighborspace)
  translation = cell.position

  # ask all walls to check their neighborspaces

  add_child(model)

func building_model_from_neighborspace(neighborspace):
  var count = 0

  for neighbor in neighborspace:
    if neighbor: count += 1

  var building_model
  match count:
    0: building_model = None.instance()
    1:
      building_model = One.instance()
      if neighborspace[0]: building_model.rotation_degrees = Vector3(0, 180, 0)
      elif neighborspace[1]: building_model.rotation_degrees = Vector3(0, 90, 0)
      elif neighborspace[2]: building_model.rotation_degrees = Vector3(0, 0, 0)
      elif neighborspace[3]: building_model.rotation_degrees = Vector3(0, 270, 0)
    2:
      match neighborspace:
        [true, false, true, false]:
          building_model = TwoAcross.instance()
        [false, true, false, true]:
          building_model = TwoAcross.instance()
          building_model.rotation_degrees = Vector3(0,90,0)
        [true, true, false, false]:
          building_model = TwoAngle.instance()
          building_model.rotation_degrees = Vector3(0,180,0)
        [false, true, true, false]:
          building_model = TwoAngle.instance()
          building_model.rotation_degrees = Vector3(0,90,0)
        [false, false, true, true]:
          building_model = TwoAngle.instance()
          building_model.rotation_degrees = Vector3(0,0,0)
        [true, false, false, true]:
          building_model = TwoAngle.instance()
          building_model.rotation_degrees = Vector3(0,270,0)
    3:
      building_model = Three.instance()
      if not neighborspace[0]: building_model.rotation_degrees = Vector3(0, 90, 0)
      elif not neighborspace[1]: building_model.rotation_degrees = Vector3(0, 0, 0)
      elif not neighborspace[2]: building_model.rotation_degrees = Vector3(0, 270, 0)
      elif not neighborspace[3]: building_model.rotation_degrees = Vector3(0, 180, 0)
      # rotation
    4: building_model = Four.instance()

  return building_model


# Wall/Neighborspace rotation notes
#           0        90,      180,     270
#    4-way: 1,1,1,1
#    3-way: 1,1,1,0; 1,1,0,1; 1,0,1,1; 0,1,1,1
#  2-angle: 1,1,0,0; 1,0,0,1; 0,0,1,1; 0,1,1,0
# 2-across: 1,0,1,0; 0,1,0,1
#        1: 1,0,0,0; 0,0,0,1; 0,0,1,0; 0,1,0,0
#     none: 0,0,0,0
