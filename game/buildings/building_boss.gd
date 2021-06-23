extends ModelBoss

func after_added(_resource, _scene):
  update_neighborspaces()

func after_removed(_resource):
  update_neighborspaces()

func update_neighborspaces():
  for scene in scenes.values():
    scene.cell.update_neighborspace()
