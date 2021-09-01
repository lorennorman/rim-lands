extends Label

var test_name
var test_func

const label_template = "[%s] %s"

func _init(new_test_name, new_test_func).():
  test_name = new_test_name
  test_func = new_test_func

  text = label_template % [" ", test_name]

func run():
  var return_value = test_func.call_func()

  if return_value:
    text = label_template % [".", test_name]
  else:
    text = label_template % ["X", test_name]
