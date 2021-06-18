# TODO:

## Save/Load/Popover UI/File System
- [ ] bug: loading is not yield-safe (active jobs in simulator crash after load)
- [ ] make file selection loader
- [ ] make file selection saver
- [ ] make autosave system

## Simulation/Units/Ticks
- [ ] define ticks in terms of irl

## Time/Days/Nights/Seasons
- [ ] pause/resume/speeds +|++|+++

## Building
- [ ] set maximum size of build job marker square
- [ ] min size: 3
- [ ] wireframe shader for build job markers
- [ ] build doors
- [ ] add a/v effects to construction
- [ ] remodel wall sections in CSG maybe?
- [ ] block double-building on same cell
- [ ] evict pawn from cell upon building construction
- [ ] "give them blueprints and they will adore you"

## GameState & Scenarios
- [ ] extract a scenario builder util from game state
- [ ] make a gui scenario editor using scenario builder util
- [ ] extract a Node version of the resource manager pattern we've been using:
  - parameterize scene to be .instance()'d
  - customize the "key" function call to the signaled model
  - common teardown func
- [ ] observable resource generation utils
  - use a common query/update pattern
  - all updates signal with delta information
  - subscribe to individual attributes support
  - always preserves save/load-ability


## GUI
- [ ] move save/load/new into pause menu popover
- [ ] make UI big (theme?), easy to splash around and get things done

## Bugs/Refactors
- [ ] node for ray cast

## Pawns
- [ ] animate walk
- [ ] generic "working" animation

## Generators
- [ ] blow out job types, experiment
- [ ] blow out skills, stat-skill formulas for job proficiency
- [ ] blow out item types



## Done:
- [x] add wooden material to walls
- [x] fix save/load/gamestate-buildup/-teardown:
  - fast-teardown signals & implementations
  - clear/rebuild map_terrain
  - remember buildings in game state
  - truly unload/reload Resources (godot!!)
- [x] bug: be resilient to pawns being unable to path jobs
- [x] pawn directory
- [x] pawn pathfinding
- [x] pull jobs by proximity
- [x] extend job radius to 8 surrounding
- [x] buildings block a*
- [x] make multiple scenarios as savegames
- [x] fix the camera
- [x] pawn stats
- [x] implement Move job
- [x] apply aura particle system to a pawn
- [x] download particle system textures
- [x] add custom fonts
- [x] use a global event bus
- [x] check into git
- [x] experiment with terrain normal
- [x] reorganize Map for save/load
- [x] GameState resource, save/load, listeners, teardown routines
- [x] implement build wall with interlocking wall models
