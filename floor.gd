extends Node

enum {
	NOT_VISITED = -1,
	VISITED = 0b1, # 1
	START = 0b10, # 2
	BOSS = 0b100 # 4
}

const START_CELL := Vector2(0,0)

var _grid := TileMap.new()

var _astar := AStar2D.new()
var _pos_to_point := {}

func _ready():
	_set_new_grid()
	_astar_setup()
	_grid_add_flag(get_furthest_room_from_start(), BOSS)


# # # # # # # # #
#     Astar     #
# # # # # # # # #

## Overrides the current astar with a new config with the current grid
func _astar_setup() -> void:
	_astar.clear()
	_astar_add_points()
	_astar_connect_points()


func _astar_add_points() -> void:
	var i := 0
	for point in _grid.get_used_cells():
		_astar.add_point(i, point)
		_pos_to_point[point] = i
		i += 1

func _astar_connect_points() -> void:
	for point in _astar.get_points():
		var pos := _astar.get_point_position(point)
		for neigh in _find_neighboring_cells(pos):
			_astar.connect_points(point, _pos_to_point[neigh])

func _find_neighboring_cells(cell: Vector2) -> Array:
	var neigh: Array = []
	for dir in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]:
		if _grid.get_cellv(cell + dir) != -1:
			neigh.append(cell + dir)

	return neigh

func get_furthest_room_from_start() -> Vector2:
	var furthest_path: PoolVector2Array

	var used_cells = _grid.get_used_cells()
	used_cells.shuffle() # Shuffle to randomize boss room pos furthermore
	for cell in used_cells:
		var point = _pos_to_point[cell]

		var path := _astar.get_point_path(point, _pos_to_point[START_CELL])
		if path.size() > furthest_path.size():
			furthest_path = path

	return furthest_path[0]


# # # # # # # # #
#     Grid      #
# # # # # # # # #

## Returns a randomly generated grid designed for map design
func _set_new_grid() -> void:
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
