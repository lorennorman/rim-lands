# TODO:

## Hair-brained Schemes
- [ ] Game can play itself?
  - background of main menu just starts a colony
  - take over at any time
  - screen saver? fun to really watch?


## Save/Load/Popover UI/File System
- [ ] bug: building errors after load/new
- [ ] autosave, quicksave, hotkeys


## Simulation/Units/Ticks
- [ ] define ticks in terms of irl
- [ ] speeds +|++|+++


## Areas
- [ ] farmland
- [ ] stockpile
- [ ] building interiors


## Items
- [ ] simple food


## Building: "give them blueprints"
- [ ] show 1-cell build preview before dragging
- [ ] build doors
- [ ] perf: "neighborspace" audit
### Bugs
  - [ ] evict pawn from cell upon building
### VFX
  - [ ] better build job markers
  - [ ] add a/v effects to construction
  - [ ] CSG YES!
    - [ ] model doors


## GameState & Scenarios
- [ ] Interactive New Game
  - scenario builder: operates game state
  - steps:
    - [.] terrain
      - fiddle with inputs
      - fast topography preview
      - quick random seed regen
      
    - stuff on the map
      - pawns, buildings, items
      - fiddle with inputs
      - fast 3d preview
      - click terrain to easily place
      - common builder interface
    - environment
      - time of day
      - calendar date
      - weather conditions
- [ ] observable resource generation utils
  - use a common query/update pattern
  - all updates signal with delta information
  - subscribe to individual attributes support
  - always preserves save/load-ability


## GUI
- [ ] make UI big (theme?), easy to splash around and get things done


## Bugs/Refactors
- [ ] node for ray cast


## Pawns
- [ ] name tags
- [ ] animate walk
- [ ] generic "working" animation
- [ ] idle job selection
- [ ] panicked job selection


## Generators
- [ ] blow out skills, stat-skill formulas for job proficiency
- [ ] blow out item types


# Done:
- [x] MapGridViewer for fast terrain tinkering
- [x] create The Three Rims:
  - [x] core's edge
  - [x] the rim eternal
  - [x] the voidlands
- [x] re-model walls as masked CSG
- [x] bug: failure to `unclaim()` materials
- [x] unified item management in GameState
- [x] elevation curves for terrain contour
- [x] allow selection of features
- [x] haul to build jobs
- [x] lumber graphic, label, quantity
- [x] extract ModelBoss: the resource manager pattern we've been using
- [x] make PawnBoss, BuildingBoss, ItemBoss
- [x] double-building
- [x] max size of build job marker square
- [x] min size: 3
- [x] bug: loading is not yield-safe (active jobs in simulator crash after load)
- [x] move save/load/new into pause menu popover
- [x] spacebar to pause/play
- [x] opening main menu pauses
- [x] blow out job types, experiment
- [x] make popover main menu
- [x] make file selection loader: games & scenarios
- [x] make file selection saver: games only
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
