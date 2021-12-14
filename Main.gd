extends Node

var prev_room_pos: Vector2 = Map.START_CELL
var cur_room_pos: Vector2 = Map.START_CELL

onready var room_node = $Room

func _ready():
	Map.generate_map()
	load_room(cur_room_pos)

func load_room(room: Vector2) -> void:
	var new_room = Map.rooms[room].instance()

	get_current_room().queue_free()
	room_node.call_deferred("add_child", new_room)

func save_room() -> void:
	var packed_scene = PackedScene.new()
	var room = get_current_room()

	packed_scene.pack(room)
	Map.rooms[cur_room_pos] = packed_scene


func change_room(nxt: Vector2) -> void:
	var next_room_pos := nxt + cur_room_pos

	save_room()
	load_room(next_room_pos)

	prev_room_pos = cur_room_pos
	cur_room_pos = next_room_pos

func get_current_room() -> Node2D:
	if not room_node.get_children().empty():
		return room_node.get_children()[0]
	else:
		assert("No room to get.")

	# Never supposed to reach
	return Node2D.new()
