extends Object
class_name Util


static func check_property(target, property_to_check):
  var found = false
  for property in target.get_property_list():
    if property.name == property_to_check:
      found = true
      break

  if !found:
    printerr("Mass-Assignment Error: target has no property '%s'" % property_to_check)

static func mass_assign(target, mass_assignments):
  for property in mass_assignments.keys():
    check_property(target, property)

    target.set(property, mass_assignments[property])


static func default_dict(target, defaults):
  for key in defaults:
    if not target.has(key):
      target[key] = defaults[key]


static func merge_dicts(target, patch):
  # immutable style
  var merged_dict = {}
  for key in target:
    merged_dict[key] = target[key]
  for key in patch:
    merged_dict[key] = patch[key]

  return merged_dict


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
