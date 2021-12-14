extends Node

enum {
	NOT_VISITED = -1,
	VISITED = 0b1, # 1
	START = 0b10, # 2
	BOSS = 0b100 # 4
}

const START_CELL := Vector2(0,0)

# Keys: Integer of door flags
# Values: Array of rooms having as many doors
var _room_w_door_flag: Dictionary = {}
# Keys: Vector2 of cells
# Values: String of corresponding room's packed scene
var rooms: Dictionary = {}

var map = TileMap.new()

func _ready():
	_list_room_w_door_flag()

## Returns a randomly generated map designed for map design
## Doesn't assign other flags to cells than VISITED and START
func generate_map() -> void:
	# RNG
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	# Variable room count
	var max_rooms := int(clamp(rng.randfn(16, 4), 12, 20))

	# Map generation
	_create_new_map(max_rooms)
	_poke_holes(6)
	_assign_rooms_to_map()

	# Astar
	Astar.setup(map)
	_map_add_flag(Astar.get_furthest_room_from_start(), BOSS)

func _create_new_map(max_rooms: int) -> void:
	var cur_cell := Vector2.ZERO
	var DIR = [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]
	var room_cnt := 1 # Including starter room

	map.set_cellv(cur_cell, START | VISITED)

	while room_cnt < max_rooms:
		DIR.shuffle()
		var new_room_cnt: int = randi() % 4 + 1

		for room in range(new_room_cnt):
			var next_room = DIR[room] + cur_cell

			if map.get_cellv(next_room) == NOT_VISITED:
				map.set_cellv(next_room, VISITED)
				room_cnt +=1

		cur_cell += DIR[0]


# Pokes holes in the map
func _poke_holes(tres: int) -> void:
	for cell in map.get_used_cells():
		if _get_neighbor_cnt(cell) > tres \
				and not map.get_cellv(cell) & START:
			map.set_cellv(cell, NOT_VISITED)

func _assign_rooms_to_map() -> void:
	for cell in map.get_used_cells():
		var door_flag := _get_door_flag(find_opened_doors(cell))

		# Randomizes chosen room
		_room_w_door_flag[door_flag].shuffle()

		var room_filename = _room_w_door_flag[door_flag][0]
		var room = load(room_filename).instance()

		var packed_scene = PackedScene.new()
		packed_scene.pack(room)

		rooms[cell] = packed_scene

## Takes an array of Vector2
## Returns door flags for the count of each neighbor
func _get_door_flag(cells: Array) -> int:
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

## Takes a cell of a map and returns an array of directions containing
## another map.
func find_opened_doors(cell: Vector2) -> Array:
	var neigh: Array = []
	for dir in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]:
		if map.get_cellv(cell + dir) != -1:
			neigh.append(dir)

	return neigh

## Returns an integer of neighboring tiles in a tilemap
func _get_neighbor_cnt(cur_cell: Vector2) -> int:
	var DIR := [-1, 0, 1]
	var neigh_cnt := 0

	for cellx in DIR:
		for celly in DIR:
			var test_cell := cur_cell + Vector2(cellx, celly)

			if map.get_cellv(test_cell) != NOT_VISITED:
				neigh_cnt += 1

	return neigh_cnt - 1 # Minus the cell itself

func _map_add_flag(cell: Vector2, flag: int) -> void:
	if map.get_cellv(cell) & flag:
		push_warning("Cell: " + String(cell) +
				" has aleady flag: " + String(flag) + ".")

	map.set_cellv(cell, map.get_cellv(cell) | flag)

func _map_remove_flag(cell: Vector2, flag: int) -> void:
	if map.get_cellv(cell) & flag:
		map.set_cellv(cell, map.get_cellv(cell) - flag)
	else:
		push_warning("Cell: " + String(cell) +
				" doesn't have flag: " + String(flag) + ".")

## Reads all rooms in the res://Rooms/ directory to find their doors flag.
## Writes result in _room_w_door_flag dictionary.
func _list_room_w_door_flag() -> void:
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

		if not _room_w_door_flag.has(room_neigh_cnt):
			_room_w_door_flag[room_neigh_cnt] = []

		_room_w_door_flag[room_neigh_cnt].append(room_filename)
		room_filename = dir.get_next()
		room_filename = dir.get_current_dir() + room_filename
