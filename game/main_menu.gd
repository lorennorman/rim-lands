extends WindowDialog

const savegame_dir = "res://savegames"
const scenario_dir = "res://scenarios"


func _ready():
  Events.connect("menu_pressed", self, "pause_and_popup")
  # New Game
  $MarginContainer/VBoxContainer/NewGameButton.connect("pressed", self, "new_game_clicked")
  # Load Game
  $MarginContainer/VBoxContainer/LoadGameButton.connect("pressed", self, "load_game_clicked")
  $LoadGameDialog.connect("file_selected", self, "load_game_file_selected")
  # Load Scenario
  $MarginContainer/VBoxContainer/LoadScenarioButton.connect("pressed", self, "load_scenario_clicked")
  $LoadScenarioDialog.connect("file_selected", self, "load_scenario_file_selected")
  # Save Game
  $MarginContainer/VBoxContainer/SaveGameButton.connect("pressed", self, "save_game_clicked")
  $SaveGameDialog.connect("file_selected", self, "save_game_file_selected")


func pause_and_popup():
  Events.emit_signal("pause_requested")
  popup()


func new_game_clicked():
  visible = false
  Events.emit_signal("new_world_requested")


func load_scenario_clicked():
  visible = false
  $LoadScenarioDialog.current_dir = scenario_dir
  $LoadScenarioDialog.popup()


func load_scenario_file_selected(scenario_file_path):
  Events.emit_signal("load_world_requested", scenario_file_path)


func load_game_clicked():
  visible = false
  $LoadGameDialog.current_dir = savegame_dir
  $LoadGameDialog.popup()


func load_game_file_selected(game_file_path):
  Events.emit_signal("load_world_requested", game_file_path)


func save_game_clicked():
  visible = false
  $SaveGameDialog.current_dir = savegame_dir
  $SaveGameDialog.popup()


func save_game_file_selected(game_file_path):
  print(game_file_path)
  Events.emit_signal("save_world_requested", game_file_path)
