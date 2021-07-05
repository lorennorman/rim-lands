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
