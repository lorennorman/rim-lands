extends Object

class_name Util

static func mass_assign(target, mass_assignments):
  for property in mass_assignments.keys():
    target.set(property, mass_assignments[property])
