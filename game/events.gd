# Global event bus, use as needed but try not to
# Registered as Events in the Autoload constants
# Use statically like:
#   Events.emit_signal("signal_name", params...)
#   Events.connect("signal_name", target_object, "target_object_function")

extends Node


# Timer Service
signal start_timer

# GUI
signal menu_pressed

# Inputs
signal cell_left_clicked(key)
signal cell_right_clicked(key)
signal cell_hovered(key)
signal left_drag_started()
signal left_drag_ended()
signal right_drag_started()
signal right_drag_ended()
signal selected_cell_updated
signal selected_entity_updated
signal hovered_cell_updated
signal dragged_cell_started
signal dragged_cell_updated
signal dragged_cell_ended

# Simulation/GameState Change Events
signal set_mode(mode_options)
signal pause_requested
signal mode_updated(mode_options)
signal simulator_state_updated(simulator_state)
signal game_state_teardown

# Orphaned Signals
signal job_completed(job)
