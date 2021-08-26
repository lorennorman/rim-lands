extends Control

const MapViewer = preload("res://game/gui/3d/map_viewer/map_viewer.tscn")

const SAVEGAME_DIR = "res://savegames"
const SCENARIO_DIR = "res://scenarios"

signal new_world_requested
signal load_world_requested
signal save_world_requested
signal save_world_successful
signal save_world_failed
signal quit_requested

export(NodePath) var main_menu_path
export(NodePath) var new_button_path
export(NodePath) var save_button_path
export(NodePath) var load_game_button_path
export(NodePath) var load_scenario_button_path
export(NodePath) var quit_button_path
export(NodePath) var new_menu_path
export(NodePath) var load_game_menu_path
export(NodePath) var load_scenario_menu_path
export(NodePath) var save_menu_path

onready var main_menu = get_node(main_menu_path)
onready var new_button = get_node(new_button_path)
onready var save_button = get_node(save_button_path)
onready var load_game_button = get_node(load_game_button_path)
onready var load_scenario_button = get_node(load_scenario_button_path)
onready var quit_button = get_node(quit_button_path)
onready var new_menu = get_node(new_menu_path)
onready var load_game_menu = get_node(load_game_menu_path)
onready var load_scenario_menu = get_node(load_scenario_menu_path)
onready var save_menu = get_node(save_menu_path)

var receive_state_for_save: FuncRef

func _ready():
  # New Game
  new_button.connect("pressed", self, "new_game_clicked")
  # Load Game
  load_game_button.connect("pressed", self, "load_game_clicked")
  load_game_menu.connect("file_selected", self, "load_game_file_selected")
  # Load Scenario
  load_scenario_button.connect("pressed", self, "load_scenario_clicked")
  load_scenario_menu.connect("file_selected", self, "load_scenario_file_selected")
  # Save Game
  save_button.connect("pressed", self, "save_game_clicked")
  save_menu.connect("file_selected", self, "save_game_file_selected")
  # Quit
  quit_button.connect("pressed", self, "quit_clicked")


func popup():
  visible = true
  main_menu.popup()


func new_game_clicked():
  emit_signal("new_world_requested")


func load_scenario_clicked():
  main_menu.visible = false
  load_scenario_menu.current_dir = SCENARIO_DIR
  load_scenario_menu.popup()


func load_scenario_file_selected(scenario_file_path):
  emit_signal("load_world_requested", ResourceLoader.load(scenario_file_path, "Resource", false))


func load_game_clicked():
  main_menu.visible = false
  load_game_menu.current_dir = SAVEGAME_DIR
  load_game_menu.popup()


func load_game_file_selected(game_file_path):
  emit_signal("load_world_requested", ResourceLoader.load(game_file_path, "Resource", false))


func save_game_clicked():
  main_menu.visible = false
  save_menu.current_dir = SAVEGAME_DIR
  save_menu.popup()


func save_game_file_selected(game_file_path):
  emit_signal("save_world_requested", game_file_path)
  if !receive_state_for_save:
    printerr("Nothing to save!")
    return

  var state_to_save = receive_state_for_save.call_func()
  if ResourceSaver.save(game_file_path, state_to_save) != OK:
    printerr("Error saving GameState")
    emit_signal("save_world_failed")

  else:
    emit_signal("save_world_successful")


func quit_clicked():
  emit_signal("quit_requested")
