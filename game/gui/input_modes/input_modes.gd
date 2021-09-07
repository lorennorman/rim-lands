
var store
var mode_controller: ModeController

const MODE_CONTROLLERS = {
  Enums.Mode.SELECT: SelectMode,
  Enums.Mode.BUILD: BuildMode,
  Enums.Mode.CHOP: ChopMode,
  Enums.Mode.SOW: SowMode,
}

func _init():
  mode_controller = SelectMode.new()
  Events.connect("mode_updated", self, "mode_updated")
  Events.connect("cell_right_clicked", self, "cell_right_clicked")
  Events.connect("dragged_cell_updated", self, "dragged_cell_updated")
  Events.connect("dragged_cell_started", self, "dragged_cell_started")
  Events.connect("dragged_cell_ended", self, "dragged_cell_ended")


func cell_right_clicked(cell):
  if mode_controller:
    mode_controller.cancel(cell)


func mode_updated(mode_params):
  if MODE_CONTROLLERS.has(mode_params.mode):
    mode_controller = MODE_CONTROLLERS[mode_params.mode].new()
    mode_controller.store = store
  else:
    mode_controller = null


func dragged_cell_started(start, end):
  if mode_controller:
    mode_controller.consider_from_to(start, end)


func dragged_cell_updated(start: MapCell, end: MapCell):
  if mode_controller:
    mode_controller.consider_from_to(start, end)


func dragged_cell_ended(start, end):
  if mode_controller:
    mode_controller.confirm_from_to(start, end)
