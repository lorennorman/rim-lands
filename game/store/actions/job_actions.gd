extends Object

const JobMap = {
  Enums.Jobs.BUILD: BuildJob,
  Enums.Jobs.CHOP: ChopJob,
  Enums.Jobs.SOW: Job
}

func action_add_job(store, payload):
  var job_class = JobMap[payload.job_type]
  var job = job_class.new(payload)
  store.game_state.jobs.push_back(job)
  StateActivator.activate_job(job, store.map)
  store.emit_signal("job_added", job)
  store.emit_signal("mutation", "jobs")


func action_update_job(_store, payload):
  var job: Job = payload["job"]
  var updates = payload["updates"]

  for key in updates.keys():
    job[key] = updates[key]

  job.emit_signal("updated", job)


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
