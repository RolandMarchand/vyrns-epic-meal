extends Node

var rooms: Dictionary = {}
var room_doors: Dictionary = {}

func _ready():
	_list_room_doors()

func load_room(room: String) -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(rooms[room].instance())

func save_room(room: String) -> void:
	var packed_scene = PackedScene.new()
	packed_scene.pack(get_tree().get_current_scene())

	if Save.rooms.has(name):
		push_warning("Overriding room " + room + " in Save singleton.")
	Save.rooms[name] = packed_scene

func _list_room_doors():
	var dir := Directory.new()
	# warning-ignore:return_value_discarded
	dir.open("res://Rooms/")
	# warning-ignore:return_value_discarded
	dir.list_dir_begin(true, true)

	var room_filename: String = dir.get_next()
	print(dir.get_current_dir())
	room_filename = dir.get_current_dir() + room_filename

	while room_filename.trim_prefix("res://Rooms/") != "":
		room_doors[room_filename] = load(room_filename).instance().neighbors
		room_filename = dir.get_next()
		room_filename = dir.get_current_dir() + room_filename

	print("lmao")
