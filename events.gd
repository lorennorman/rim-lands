# Global event bus
# Registered as Events in the Autoload constants
# Use statically like:
#   Events.emit_signal("signal_name", params...)
#   Events.connect("signal_name", target_object, "target_object_function")

extends Node

# New/Load/Save Data
signal new_world_requested
signal load_world_requested
signal save_world_requested

# Timer
signal start_timer

# Inputs
signal cell_left_clicked(key)
signal cell_right_clicked(key)
signal cell_hovered(key)

# GUI State Machine
signal selected_cell_updated
signal selected_entity_updated
signal hovered_cell_updated
signal set_mode(mode_options)

# Simulator changes
signal pawn_added(pawn)
signal pawn_removed(pawn)

signal job_added(job)
signal job_removed(job)
signal job_completed(job)

signal building_added(building)
signal building_removed(building)
