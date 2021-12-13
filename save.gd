extends Node

var rooms: Dictionary = {}

func load_room(room: Object) -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(rooms[room])

func save_room(room: Object) -> void:
	var packed_scene = PackedScene.new()
	packed_scene.pack(room)

	if Save.rooms.has(room):
		push_warning("Overriding room " + str(room) + " in Save singleton.")
	Save.rooms[room] = packed_scene
