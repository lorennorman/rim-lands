extends JobMode
class_name ChopMode


func new_job_at(cell):
  return ChopJob.new({ "map_cell": cell })


func cell_selection_algorithm(start, end):
  # TODO: only on cells containing mature forest
  return one_out_of(5, filled_square_of_cells(start, end))
