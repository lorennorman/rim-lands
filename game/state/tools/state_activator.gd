extends Object
class_name StateActivator

static func build_map(map_grid, map):
  ### Map ###
  map.astar.reserve_space(pow(map_grid.map_size, 2))
  map.cells = {}

  var environment = map_grid.environment_settings
  var terrain_noise = Util.ZeroOneNoise.new(map_grid.terrain_seed)

  for z in map_grid.map_size:
    for x in map_grid.map_size:
      # Establish terrain noise value at this position
      var nx = (x * environment.scale)
      var nz = (z * environment.scale)
      var terrain_noise_value = terrain_noise.get_noise_2d(nx, nz)

      # Plot terrain noise value on an elevation curve
      var height = environment.height * environment.curve.interpolate(terrain_noise_value)
      # Plot terrain noise value on a color gradient
      var color = environment.gradient.interpolate(terrain_noise_value)

      # A new MapCell for this position
      var map_cell = MapCell.new()
      # The MapGrid we're a part of, so we can lookup neighbors, etc
      map_cell.map_grid = map_grid
      # Apply the terrain
      map_cell.terrain = color
      # Calculate 3D position, mapping us to the terrain, averaging between points
      var average_height
      if x == 0 or z == 0:
        average_height = height
      else:
        var old_height = map.lookup_cell("%d,%d" % [x-1, z-1]).position.y
        average_height = (height + old_height) / 2

      var position = Vector3((x+0.5), average_height, (z+0.5))

      # Store and index position
      map_cell.position = position
      map.set_cell(position, map_cell)

      # Generate, store, and index location key
      var location_key = "%d,%d" % [x, z]
      map_cell.location = location_key
      map.set_cell(location_key, map_cell)

      # calculate navigability
      var lowest_navigable_height = environment.navigable_range[0] * environment.height
      var highest_navigable_height = environment.navigable_range[1] * environment.height
      # disable nav if the cell is outside of the navigable range
      map_cell.disabled = (height < lowest_navigable_height) or (height > highest_navigable_height)

      # add the point to the astar network
      var astar_id = map.astar.get_available_point_id()
      map.astar.add_point(astar_id, position)

      # connect the point to its already-added astar neighbors
      if z > 0:
        var up_cell = map.lookup_cell("%d,%d" % [x, z-1])
        map.astar.connect_points(astar_id, up_cell.astar_id)
      if x > 0:
        var left_cell = map.lookup_cell("%d,%d" % [x-1, z])
        map.astar.connect_points(astar_id, left_cell.astar_id)
      if x > 0 and z > 0:
        var upleft_cell = map.lookup_cell("%d,%d" % [x-1, z-1])
        map.astar.connect_points(astar_id, upleft_cell.astar_id)
      if z > 0 and x < map_grid.map_size - 2:
        var upright_cell = map.lookup_cell("%d,%d" % [x+1, z-1])
        map.astar.connect_points(astar_id, upright_cell.astar_id)

      if map_cell.disabled:
        map.astar.set_point_disabled(astar_id, true)

      # Store and index astar id
      map_cell.astar_id = astar_id
      map.set_cell(astar_id, map_cell)


static func stuff_on_map(store, map):
  # ### Stuff on the Map ###
  for pawn in store.pawns:
    var map_cell = map.lookup_cell(pawn.location)

    # bail if exists and we're not forcing
    if map_cell.pawn:
      printerr("Pawn collision at %s: " % [map_cell.location])
      continue

    # set pawn <-> cell
    map_cell.pawn = pawn
    pawn.map_cell = map_cell

  store.emit_signal("pawn_collection_added", store.pawns)

  for item in store.items:
    if item.owner is String:
      var cell = map.lookup_cell(item.location)
      item.map_cell = cell
      cell.add_item(item)
    else:
      item.owner.add_item(item)

  for job in store.jobs:
    var cell = map.lookup_cell(job.location)
    if not cell.can_take_job(job):
      printerr("Attempted to assign job to ineligible cell: %s -> %s" % [job, cell])

    job.map_cell = cell
    # unless i have a parent and they occupy this cell...
    if not (job.parent and job.map_cell == job.parent.map_cell):
      # ...i occupy this cell
      cell.feature = job

    # FIXME: nested add_job for sub-jobs, something isn't right here
    #   won't the subjobs get saved/loaded normally, and thus not need the
    #   parent job to add them?
    if not job.can_be_completed():
      for sub_job in job.sub_jobs:
        pass
        # add_job(sub_job)

  for building in store.buildings:
    var cell = map.lookup_cell(building.location)
    building.map_cell = cell
    cell.feature = building

  for forest in store.forests:
    var cell = map.lookup_cell("%d,%d" % [forest.x, forest.z])
    forest["position"] = cell.position
    cell.feature = "Forest"
