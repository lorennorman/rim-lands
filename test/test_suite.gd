tool
extends VBoxContainer

const TestLabel = preload("./test_label.gd")
const Spy = preload("./spy.gd")

# func get_spy(method_name): return Spy.new(method_name)
var suite
export(Script) var suite_script setget set_suite_script
func set_suite_script(new_suite_script):
  suite_script = new_suite_script
  suite = suite_script.new()


export(String) var title setget set_title
func set_title(new_title):
  title = new_title
  if get_node("Label") and title: $Label.text = title


func _ready():
  set_title(title)
  # enqueue all tests to run
  var test_labels = []
  for name in get_suite_test_methods():
    # observer label for each test
    var label = TestLabel.new(name, funcref(suite, name))
    test_labels.push_back(label)
    $Tests.add_child(label)

  for test in test_labels:
    var return_value = test.run()
    if return_value is GDScriptFunctionState && return_value.is_valid():
      yield(return_value, "completed")


# get an array of strings of every method on this class starting with test_
func get_suite_test_methods():
  var test_methods = []
  if not suite: return test_methods

  for method in suite.get_method_list():
    if method.name.find("test_") == 0:
      test_methods.push_back(method.name)
  return test_methods
