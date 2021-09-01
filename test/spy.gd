
var spy_on
var called = false
var arg_1
var arg_2
var arg_3


func _init(to_spy_on):
  spy_on = to_spy_on


func spy(var_1=null, var_2=null, var_3=null):
  called = true
  arg_1 = var_1
  arg_2 = var_2
  arg_3 = var_3
