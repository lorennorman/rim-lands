extends JobMode
class_name SowMode


func new_job_at(cell):
  return Job.new({ "map_cell": cell, "job_type": Enums.Jobs.SOW })


func cell_selection_algorithm(start, end):
  # TODO: only on arable land
  return one_out_of(2, filled_square_of_cells(start, end))
