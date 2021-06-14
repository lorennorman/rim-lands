extends HBoxContainer

const PawnDirectoryEntry = preload("./pawn_directory_entry.tscn")

var pawn_directory_entries := {}

func _ready():
  Events.connect("pawn_added", self, "pawn_added")
  Events.connect("pawn_removed", self, "pawn_removed")
  Events.connect("game_state_teardown", self, "teardown")


func pawn_added(pawn: Pawn):
  var new_entry = PawnDirectoryEntry.instance()
  new_entry.pawn = pawn
  pawn_directory_entries[pawn.key] = new_entry
  # conditionally add a separator
  if pawn_directory_entries.size() > 1:
    add_child(VSeparator.new())
  add_child(new_entry)


func pawn_removed(pawn: Pawn):
  var related_entry = pawn_directory_entries[pawn.key]
  # conditionally remove the separator
  if pawn_directory_entries.size() > 1:
    var pawn_pos = related_entry.get_position_in_parent()
    var separator = get_child(pawn_pos - 1)
    if not separator:
      separator = get_child(pawn_pos + 1)
    separator.queue_free()
  related_entry.queue_free()
  pawn_directory_entries.erase(pawn.key)


func teardown():
  for node in get_children(): node.queue_free()
  pawn_directory_entries.clear()
