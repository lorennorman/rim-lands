extends JobMode
class_name ChopMode


func new_job_details():
  return { "job_type": Enums.Jobs.CHOP }


func cell_selection_algorithm(start, end):
  # TODO: only on cells containing mature forest
  var forest_cells = []
  for cell in filled_square_of_cells(start, end):
    if cell.feature is String and cell.feature == "Forest":
      forest_cells.push_back(cell)

  return forest_cells
