extends Object
class_name Util


static func mass_assign(target, mass_assignments):
  for property in mass_assignments.keys():
    target.set(property, mass_assignments[property])


static func default_dict(target, defaults):
  for key in defaults:
    if not target.has(key):
      target[key] = defaults[key]


static func merge_dicts(target, patch):
  for key in patch:
    target[key] = patch[key]


static func is_between(target, minimum, maximum):
  return target > minimum and target < maximum


static func random_integer():
  var rng = RandomNumberGenerator.new()
  rng.randomize()

  return rng.randi()

class ZeroOneNoise:
  extends Object

  var noise: OpenSimplexNoise
  var scale_factor = 1

  func _init(noise_seed, a_scale_factor=1):
    noise = OpenSimplexNoise.new()
    noise.seed = noise_seed
    scale_factor = a_scale_factor

  func get_noise_2d(x, y):
    return inverse_lerp(-1, 1, noise.get_noise_2d(( x*scale_factor ), ( y*scale_factor )))
