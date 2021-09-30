extends Object

### Expect, test run inspection ###
var failure_reason = null

func expect(conditional, message):
  # already been a failure
  if failure_reason: return false

  if not conditional:
    failure_reason = message
    return false

  return true


### Spies ###
const Spy = preload("./spy.gd")

func get_spy(method_name): return Spy.new(method_name)

func spy_on(target, signal_name):
  var spy = get_spy(signal_name)
  target.connect(signal_name, spy, "spy")

  return spy
