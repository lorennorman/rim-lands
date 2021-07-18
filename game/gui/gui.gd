extends Spatial

var game_state
var gui_state

func _ready():
  Events.connect("hovered_cell_updated", self, "hovered_cell_updated")
  Events.connect("selected_entity_updated", self, "selected_entity_updated")
  Events.connect("dragged_cell_updated", self, "dragged_cell_updated")
  Events.connect("left_drag_started", self, "left_drag_started")
  Events.connect("left_drag_ended", self, "left_drag_ended")


func hovered_cell_updated(cell):
  var disabled = game_state.map_grid.astar.is_point_disabled(cell.astar_id)
  var astar_text = "AStar: [%s] %d" % ['X' if disabled else '  ', cell.astar_id]
  $Menus/Left/VBoxContainer/AStarHoverLabel.text = astar_text

  var pawn_name = cell.pawn.character_name if cell.pawn else ""
  $Menus/Left/VBoxContainer/PawnHoverLabel.text = "Pawn: %s" % pawn_name

  var feature_text = cell.feature.to_string() if cell.feature else ""
  $Menus/Left/VBoxContainer/FeatureHoverLabel.text = "Feature: %s" % feature_text

  var color = cell.terrain if cell.terrain else Color(0)
  $Menus/Left/VBoxContainer/TerrainHoverLabel/ColorRect.color = color

  var location_text = cell.location
  $Menus/Left/VBoxContainer/LocationHoverLabel.text = "Location: %s" % location_text


func selected_entity_updated(entity):
  var focus_text = entity

  # TODO: try multiline strings """
  if entity is Pawn:
    focus_text = "%s\n  %s" % [entity.character_name, entity.race]
    for item in entity.items:
      focus_text += "\n%s: %s" % [item, entity.items[item]]

  elif entity is Building:
    focus_text = "Building: %s\n" % entity.type
    focus_text += "  Location: %s\n" % entity.location

  elif entity is Item:
    focus_text = "Item: %s (x%s)\n" % [entity.type, entity.quantity]
    focus_text += "  Location: %s\n" % entity.location
    focus_text += "  Claimed: %s\n" % entity.claimant.character_name if entity.is_claimed() else "No"

  elif entity is Job:
    if entity is BuildJob:
      focus_text = "Build Job\n"
      focus_text += "  %s/100\n" % entity.percent_complete
      focus_text += "  Completable: %s\n" % ("Yes" if entity.completable else "No")
      focus_text += "  Materials: %s\n" % entity.materials_present
    elif entity is HaulJob:
      focus_text = "Haul Job\n"
      focus_text += "  Material: %s\n" % entity.material
      focus_text += "  Quantity: %s\n" % entity.quantity
    else:
      focus_text = "Job\n"

    if entity.sub_jobs.size() > 0:
      focus_text += "Sub-Jobs: %s" % entity.sub_jobs.size()

  $Menus/Left/VBoxContainer/TargetFocus.text = "%s" % focus_text


var draggable_building_origin: MapCell
func dragged_cell_updated(cell: MapCell):
  if gui_state.mode == Enums.Mode.BUILD:
    remove_job_markers()
    if not draggable_building_origin: draggable_building_origin = cell

    if draggable_building_origin and cell:
      add_job_markers_between(draggable_building_origin, cell)


func left_drag_ended():
  draggable_building_origin = null
  for building_marker in building_markers:
    game_state.add_job(building_marker.job)
  remove_job_markers()


func left_drag_started():
  draggable_building_origin = gui_state.hovered_cell


var building_markers = []
func remove_job_markers():
  for marker in building_markers:
    marker.queue_free()
  building_markers = []


const MIN_BUILDING_SIZE = 3
const MAX_BUILDING_SIZE = 10
const JobMarker = preload("res://game/gui/3d/job_marker.tscn")
func add_job_markers_between(x1z1, x2z2):
  var x1z1x = x1z1.x
  var x2z2x = x2z2.x
  var min_x = x1z1x - MAX_BUILDING_SIZE
  var max_x = x1z1x + MAX_BUILDING_SIZE
  var small_x = max(min_x, min(x1z1x, x2z2x))
  var large_x = min(max_x, max(x1z1x, x2z2x))
  var x_size = large_x - small_x

  var x1z1z = x1z1.z
  var x2z2z = x2z2.z
  var min_z = x1z1z - MAX_BUILDING_SIZE
  var max_z = x1z1z + MAX_BUILDING_SIZE
  var small_z = max(min_z, min(x1z1z, x2z2z))
  var large_z = min(max_z, max(x1z1z, x2z2z))
  var z_size = large_z - small_z

  if x_size < MIN_BUILDING_SIZE and (x_size <= z_size):
    large_x = x1z1x
    small_x = x1z1x
  if z_size < MIN_BUILDING_SIZE and (z_size < x_size):
    large_z = x1z1z
    small_z = x1z1z

  var square_cells = []
  for x in range(small_x, large_x+1):
    # top wall
    square_cells.push_back(game_state.map_grid.lookup_cell("%d,%d" % [x, small_z]))
    if small_z != large_z:
      # bottom wall
      square_cells.push_back(game_state.map_grid.lookup_cell("%d,%d" % [x, large_z]))

  if small_z != large_z:
    for z in range(small_z+1, large_z):
      # left wall
      square_cells.push_back(game_state.map_grid.lookup_cell("%d,%d" % [small_x, z]))
      if small_x != large_x:
        # right wall
        square_cells.push_back(game_state.map_grid.lookup_cell("%d,%d" % [large_x, z]))

  for cell in square_cells:
    var job = BuildJob.new({
      "location": cell.location,
      "map_cell": cell,
      "building_type": Enums.Buildings.WALL,
      "materials_required": {
        Enums.Items.LUMBER: 20
      }
    })
    var job_marker = JobMarker.instance()
    job_marker.job = job
    building_markers.push_back(job_marker)
    add_child(job_marker)
