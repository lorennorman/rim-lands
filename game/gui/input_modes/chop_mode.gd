extends JobMode
class_name ChopMode


func new_job_at(cell):
  return ChopJob.new({ "map_cell": cell })


func cell_selection_algorithm(start, end):
  return one_out_of(5, filled_square_of_cells(start, end))


func one_out_of(denominator: int, collection):
  var random_filtered = []
  for cell in collection:
    if randi() % denominator == 0:
      random_filtered.push_back(cell)

  return random_filtered
