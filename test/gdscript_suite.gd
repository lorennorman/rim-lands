extends "./test.gd"

func test_array_comparison():
  expect(not [], "empty arrays are false")
  expect([1], "non-empty arrays are true")
  expect([] == [], "empty arrays should be equal")
  expect([1, 2, 3] == [1, 2, 3], "arrays are compared by their contents")


func test_resource_with_initialized_arrays():
  var res1 = ResourceWithInitializedProperties.new()
  var res2 = ResourceWithInitializedProperties.new()

  expect(res1 != res2, "Resource instances are different.")

  expect(res2.arr.size() == 0, "Arrays start empty")
  res1.arr.push_back(1) # modify res1's array, then check res2's array for the change
  expect(res2.arr[0] == 1, "Resources that initialize share the same arrays")

  var res3 = ResourceWithInitializedProperties.new()
  expect(res1.arr == res3.arr, "Even Resources created later")


func test_resource_without_initialized_arrays():
  var res1 = ResourceWithoutInitializedProperties.new()
  var res2 = ResourceWithoutInitializedProperties.new()

  expect(res1.arr == [], "Arrays get initialized automatically")
  expect(res1.arr == res2.arr, "Initialized arrays match")
  res1.arr.push_back(1)
  expect(res1.arr != res2.arr, "One array changed, arrays no longer match")


func test_resource_with_initialized_resources():
  var res1 = ResourceWithInitializedProperties.new()
  var res2 = ResourceWithInitializedProperties.new()

  expect(res1.res != null, "Initialized resources are not null")
  expect(res1.res != res2.res, "Initialized resources are not equal")


func test_resource_without_initialized_resources():
  var res1 = ResourceWithoutInitializedProperties.new()
  var res2 = ResourceWithoutInitializedProperties.new()

  expect(res1.res == null, "Non-initialized subresources are null")
  expect(res1.res == res2.res, "Non-initialized subresources are same")

  res2.res = Resource.new()
  expect(res1.res != res2.res, "Once set, subresources are not equal")


class ResourceWithInitializedProperties:
  extends Resource

  export(Resource) var res = Resource.new()
  export(Array, Resource) var arr = []


class ResourceWithoutInitializedProperties:
  extends Resource

  export(Resource) var res
  export(Array, Resource) var arr
