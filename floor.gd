extends Node

enum {
	NOT_VISITED = -1,
	VISITED = 0b1, # 1
	START = 0b10, # 2
	BOSS = 0b100 # 4
}

const START_CELL := Vector2(0,0)

var _grid := TileMap.new()



# Keys: Integer of doors, binary flags
# Values: Array of rooms having as many doors
var _room_w_door_cnt: Dictionary = {}
# Keys: Vector2 of cells
# Values: String of corresponding room's packed scene
var _room_config: Dictionary = {}

var prev_room: Vector2 = START_CELL
var cur_room: Vector2 = START_CELL
onready var main = get_tree().get_root().get_node("Main")

func _ready():
	_list_room_w_door_cnt()

	_create_new_grid()
	Astar.setup(_grid)
	_grid_add_flag(Astar.get_furthest_room_from_start(), BOSS)

	_assign_rooms_to_grid()

	load_room(START_CELL)

func load_room(room: Vector2):
	for room in get_tree().get_nodes_in_group("rooms"):
		room.queue_free()

	var new_room = _room_config[room].instance()

	main.call_deferred("add_child", new_room)

func save_room():
	var packed_scene = PackedScene.new()

	for room in main.get_children():
		if room.is_in_group("rooms"):
			packed_scene.pack(room)
			_room_config[cur_room] = packed_scene

			return

	assert("No room to save.")


func change_room(nxt: Vector2) -> void:
	var next_room := nxt + cur_room

	save_room()
	load_room(next_room)

	prev_room = cur_room
	cur_room = next_room

func _assign_rooms_to_grid() -> void:
	var tmp = _grid.get_used_cells()
	for cell in _grid.get_used_cells():
		var neigh_cnt := count_neighbors(find_neighboring_cells_dir(cell))
		_room_w_door_cnt[neigh_cnt].shuffle()
		var room_filename = _room_w_door_cnt[neigh_cnt][0]
		var room = load(room_filename).instance()

		var packed_scene = PackedScene.new()
		packed_scene.pack(room)

		_room_config[cell] = packed_scene


## Takes an array of Vector2
## Returns binary flags for the count of each neighbor
func count_neighbors(cells: Array) -> int:
	var result := 0
	for cell in cells:
		match cell:
			Vector2.UP:
				result = result | 0b1
			Vector2.RIGHT:
				result = result | 0b10
			Vector2.DOWN:
				result = result | 0b100
			Vector2.LEFT:
				result = result | 0b1000

	return result

## Takes a cell of a grid and returns an array of directions containing
## another grid.
func find_neighboring_cells_dir(cell: Vector2) -> Array:
	var neigh: Array = []
	for dir in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]:
		if _grid.get_cellv(cell + dir) != -1:
			neigh.append(dir)

	return neigh



## Returns a randomly generated grid designed for map design
## Doesn't assign other flags to cells than VISITED and START
func _create_new_grid() -> void:
	# RNG
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	# Variable room count
	var max_rooms := int(clamp(rng.randfn(16, 4), 12, 20))

	generate_map(max_rooms)
	poke_holes(6)

func generate_map(max_rooms: int) -> void:
	var cur_cell := Vector2.ZERO
	var DIR = [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]
	var room_cnt := 1 # Including starter room

	_grid.set_cellv(cur_cell, START | VISITED)

	while room_cnt < max_rooms:
		DIR.shuffle()
		var new_room_cnt: int = randi() % 4 + 1

		for room in range(new_room_cnt):
			var next_room = DIR[room] + cur_cell

			if _grid.get_cellv(next_room) == NOT_VISITED:
				_grid.set_cellv(next_room, VISITED)
				room_cnt +=1

		cur_cell += DIR[0]


# Pokes holes in the map
func poke_holes(tres: int) -> void:
	for cell in _grid.get_used_cells():
		if get_neighbor_cnt(cell) > tres \
				and not _grid.get_cellv(cell) & START:
			_grid.set_cellv(cell, NOT_VISITED)

## Returns an integer of neighboring tiles in a tilemap
func get_neighbor_cnt(cur_cell: Vector2) -> int:
	var DIR := [-1, 0, 1]
	var neigh_cnt := 0

	for cellx in DIR:
		for celly in DIR:
			var test_cell := cur_cell + Vector2(cellx, celly)

			if _grid.get_cellv(test_cell) != NOT_VISITED:
				neigh_cnt += 1

	return neigh_cnt - 1 # Minus the cell itself

func _grid_add_flag(cell: Vector2, flag: int) -> void:
	if _grid.get_cellv(cell) & flag:
		push_warning("Cell: " + String(cell) +
				" has aleady flag: " + String(flag) + ".")

	_grid.set_cellv(cell, _grid.get_cellv(cell) | flag)

func _grid_remove_flag(cell: Vector2, flag: int) -> void:
	if _grid.get_cellv(cell) & flag:
		_grid.set_cellv(cell, _grid.get_cellv(cell) - flag)
	else:
		push_warning("Cell: " + String(cell) +
				" doesn't have flag: " + String(flag) + ".")

# # # # # # # # #
#     Rooms     #
# # # # # # # # #

func _list_room_w_door_cnt():
	var dir := Directory.new()
	# warning-ignore:return_value_discarded
	dir.open("res://Rooms/")
	# warning-ignore:return_value_discarded
	dir.list_dir_begin(true, true)

	var room_filename: String = dir.get_next()
	print(dir.get_current_dir())
	room_filename = dir.get_current_dir() + room_filename

	while room_filename.trim_prefix("res://Rooms/") != "":
		var room_neigh_cnt: int = load(room_filename).instance().neighbors

		if not _room_w_door_cnt.has(room_neigh_cnt):
			_room_w_door_cnt[room_neigh_cnt] = []

		_room_w_door_cnt[room_neigh_cnt].append(room_filename)
		room_filename = dir.get_next()
		room_filename = dir.get_current_dir() + room_filename
