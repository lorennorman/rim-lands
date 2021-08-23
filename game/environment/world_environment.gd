extends WorldEnvironment

func _process(delta):
  $DirectionalLight.rotate_x(delta * .04)

  if $DirectionalLight.rotation.x > 0:
    $DirectionalLight.rotate_x(deg2rad(180))
