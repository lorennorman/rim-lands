extends ModeController
class_name JobMode

var jobs = []


func new_job_at(_cell):
  printerr("Implement get_job_at(cell) for this JobMode")


func confirm(cell):
  store.add_job( new_job_at(cell) )


func consider_from_to(start, end):
  # TODO: optimize to
  # - cache jobs
  # - leverage diffing
  # - maintain observers on add

  # clear and signal existing jobs
  for job in jobs:
    store.emit_signal("job_removed", job)
  jobs.clear()

  # new and signal jobs with between algorithm
  for cell in cell_selection_algorithm(start, end):
    var job = new_job_at(cell)
    jobs.push_back(job)
    store.emit_signal("job_added", job)


func confirm_from_to(start, end):
  for job in jobs:
    # signal existing jobs
    store.emit_signal("job_removed", job)

  if start == end:
    confirm(start)
  else:
    for job in jobs:
      # transfer into the game state
      store.add_job(job)

  # clear existing jobs
  jobs.clear()


func cell_selection_algorithm(start, end):
  return square_of_cells(start, end)
