extends JobMode
class_name BuildMode

const MIN_BUILDING_SIZE = 3
const MAX_BUILDING_SIZE = 10

func new_job_at(cell):
  return BuildJob.new({
    "location": cell.location,
    "map_cell": cell,
    "building_type": Enums.Buildings.WALL,
    "materials_required": {
      Enums.Items.LUMBER: 5
    }
  })


func cell_selection_algorithm(start, end):
  return square_of_cells(start, end, MIN_BUILDING_SIZE, MAX_BUILDING_SIZE)
