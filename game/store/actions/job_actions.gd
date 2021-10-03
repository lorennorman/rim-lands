extends Object

const JobMap = {
  Enums.Jobs.BUILD: BuildJob,
  Enums.Jobs.CHOP: ChopJob
}

func action_add_job(store, payload):
  # TODO: select Job class via payload.job_type
  var job_class = JobMap[payload.job_type]
  var job = job_class.new(payload)
  store.game_state.jobs.push_back(job)
  StateActivator.activate_job(job, store.map)
  store.emit_signal("job_added", job)
  store.emit_signal("mutation", "jobs")


func action_complete_job(store, job):
  # TODO: move this into the job
  match job.job_type:
    Enums.Jobs.BUILD:
      store.action("add_building", {
        type = job.building_type,
        location = job.location
      })

  store.action("destroy_job", job)


func action_destroy_job(store, job):
  store.game_state.jobs.erase(job)
  StateActivator.deactivate_job(job)
  store.emit_signal("job_removed", job)
  store.emit_signal("mutation", "jobs")
