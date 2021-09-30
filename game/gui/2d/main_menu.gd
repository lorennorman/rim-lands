extends Control

const SAVEGAME_DIR = "res://savegames"
const SCENARIO_DIR = "res://scenarios"

signal new_world_requested
signal load_world_requested
signal save_world_requested
signal save_world_successful
signal save_world_failed
signal quit_requested

export(NodePath) var main_menu_path
export(NodePath) var load_game_menu_path
export(NodePath) var load_scenario_menu_path
export(NodePath) var save_menu_path

onready var main_menu = get_node(main_menu_path)
onready var load_game_menu = get_node(load_game_menu_path)
onready var load_scenario_menu = get_node(load_scenario_menu_path)
onready var save_menu = get_node(save_menu_path)

var receive_state_for_save: FuncRef


func popup():
  main_menu.popup()


func hide():
  main_menu.visible = false
  load_game_menu.visible = false
  load_scenario_menu.visible = false
  save_menu.visible = false


### LOADING SCENARIOS ###
func load_scenario_clicked():
  hide()
  load_scenario_menu.current_dir = SCENARIO_DIR
  load_scenario_menu.popup()


func load_scenario_file_selected(scenario_file_path):
  emit_signal("load_world_requested", ResourceLoader.load(scenario_file_path, "Resource", false))


### LOADING GAMES ###
func load_game_clicked():
  hide()
  load_game_menu.current_dir = SAVEGAME_DIR
  load_game_menu.popup()


func load_game_file_selected(game_file_path):
  emit_signal("load_world_requested", ResourceLoader.load(game_file_path, "Resource", false))


### SAVING ###
func save_game_clicked():
  hide()
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
