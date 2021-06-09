extends Spatial

const None := preload("./walls/none.tscn")
const One := preload("./walls/1_adjacent.tscn")
const TwoAcross := preload("./walls/2_across.tscn")
const TwoAngle := preload("./walls/2_angle.tscn")
const Three := preload("./walls/3_perpendicular.tscn")
const Four := preload("./walls/4_way.tscn")

var cell: MapCell setget set_cell
var model: Spatial

func _ready():
  assert(cell, "BuildingModel became _ready() without a Cell")
  cell.update_neighborspace()
  neighborspace_updated(cell)

func set_cell(new_cell):
  cell = new_cell
  var _nu = cell.connect("neighborspace_updated", self, "neighborspace_updated")
  # cell.update_neighborspace()
  neighborspace_updated(cell)

func neighborspace_updated(_cell):
  # get the existing model, remove it
  if model:
    remove_child(model)
    model.queue_free()

  # determine the appropriate model, add it
  model = building_model_from_neighborspace(cell.neighborspace)
  translation = cell.position

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
      else: printerr("Wall Model: no One position found")
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
        _: printerr("Wall Model: no Two position found")
    3:
      building_model = Three.instance()
      if not neighborspace[0]: building_model.rotation_degrees = Vector3(0, 90, 0)
      elif not neighborspace[1]: building_model.rotation_degrees = Vector3(0, 0, 0)
      elif not neighborspace[2]: building_model.rotation_degrees = Vector3(0, 270, 0)
      elif not neighborspace[3]: building_model.rotation_degrees = Vector3(0, 180, 0)
      else: printerr("Wall Model: no Three model found")
      # rotation
    4:
      building_model = Four.instance()
      building_model.rotation_degrees = Vector3(0,90,0)

  return building_model


# Wall/Neighborspace rotation notes
#           0        90,      180,     270
#    4-way: 1,1,1,1
#    3-way: 1,1,1,0; 1,1,0,1; 1,0,1,1; 0,1,1,1
#  2-angle: 1,1,0,0; 1,0,0,1; 0,0,1,1; 0,1,1,0
# 2-across: 1,0,1,0; 0,1,0,1
#        1: 1,0,0,0; 0,0,0,1; 0,0,1,0; 0,1,0,0
#     none: 0,0,0,0
