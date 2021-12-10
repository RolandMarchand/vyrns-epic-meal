extends Node

var rooms: Dictionary = {}

func load_room(room: String) -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(rooms[room].instance())

func save_room(room: String) -> void:
	var packed_scene = PackedScene.new()
	packed_scene.pack(get_tree().get_current_scene())

	if Save.rooms.has(name):
		push_warning("Overriding room " + room + " in Save singleton.")
	Save.rooms[name] = packed_scene

