extends Object
class_name StateActivator

static func activate_state(state):
  ### Map ###
  var map_grid = state.map_grid
  if map_grid.astar:
    map_grid.astar.reserve_space(pow(map_grid.map_size, 2))

  map_grid.omni_dict = {}

  var environment = StateGenerator.ENVIRONMENTS[map_grid.environment]

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
        var old_height = map_grid.lookup_cell("%d,%d" % [x-1, z-1]).position.y
        average_height = (height + old_height) / 2

      var position = Vector3((x+0.5), average_height, (z+0.5))

      # Store and index position
      map_cell.position = position
      map_grid.set_cell(position, map_cell)

      # Generate, store, and index location key
      var location_key = "%d,%d" % [x, z]
      map_cell.location = location_key
      map_grid.set_cell(location_key, map_cell)

      if map_grid.astar:
        # calculate navigability
        var lowest_navigable_height = environment.navigable_range[0] * environment.height
        var highest_navigable_height = environment.navigable_range[1] * environment.height
        # disable nav if the cell is outside of the navigable range
        map_cell.disabled = (height < lowest_navigable_height) or (height > highest_navigable_height)

        # add the point to the astar network
        var astar_id = map_grid.astar.get_available_point_id()
        map_grid.astar.add_point(astar_id, position)

        # connect the point to its already-added astar neighbors
        if z > 0:
          var up_cell = map_grid.lookup_cell("%d,%d" % [x, z-1])
          map_grid.astar.connect_points(astar_id, up_cell.astar_id)
        if x > 0:
          var left_cell = map_grid.lookup_cell("%d,%d" % [x-1, z])
          map_grid.astar.connect_points(astar_id, left_cell.astar_id)
        if x > 0 and z > 0:
          var upleft_cell = map_grid.lookup_cell("%d,%d" % [x-1, z-1])
          map_grid.astar.connect_points(astar_id, upleft_cell.astar_id)
        if z > 0 and x < map_grid.map_size - 2:
          var upright_cell = map_grid.lookup_cell("%d,%d" % [x+1, z-1])
          map_grid.astar.connect_points(astar_id, upright_cell.astar_id)

        if map_cell.disabled:
          map_grid.astar.set_point_disabled(astar_id, true)

        # Store and index astar id
        map_cell.astar_id = astar_id
        map_grid.set_cell(astar_id, map_cell)

        # map_cell.connect("pathing_updated", self, "pathing_updated")

  # ### Stuff on the Map ###
  # for pawn in state.pawns: buildup_pawn(pawn)
  # for item in state.items: buildup_item(item)
  # for job in state.jobs: buildup_job(job)
  # for building in state.buildings: buildup_building(building)
  # for forest in map_grid.forests: buildup_forest(forest)
  #
  # # signal for all existing resources
  # for pawn in state.pawns: Events.emit_signal("pawn_added", pawn)
  # for item in state.items: Events.emit_signal("item_added", item)
  # for job in state.jobs: Events.emit_signal("job_added", job)
  # for building in state.buildings: Events.emit_signal("building_added", building)
  # for forest in map_grid.forests: Events.emit_signal("forest_added", forest)
