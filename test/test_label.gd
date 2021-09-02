extends Label

var test_method_name
var test

const label_template = "[%s] %s"
const failure_template = label_template + "\n     REASON: %s"

func _init(new_test_method_name, new_test).():
  test_method_name = new_test_method_name
  test = new_test

  text = label_template % [" ", test_method_name]

func run():
  test.call(test_method_name)

  if test.failure_reason:
    text = failure_template % ["X", test_method_name, test.failure_reason]
  else:
    text = label_template % [".", test_method_name]
