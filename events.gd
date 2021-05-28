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
signal node_lclicked(key)
signal node_rclicked(key)
signal node_hovered(key)

# Simulator changes
signal pawn_added(pawn)
signal pawn_removed(pawn)

signal job_added(job)
signal job_removed(job)
signal job_completed(job)
