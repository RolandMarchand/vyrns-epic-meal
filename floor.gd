extends Node

enum {NOT_VISITED = -1, VISITED = 0b1, START = 0b10} # -1, 1, 2

var _grid: TileMap = get_new_grid()

func _ready():
	pass

func get_furthest_room_from_start(grid: TileMap) -> int:
	for tile in _grid.get_used_cells():
		print(_grid.get_cellv(tile))
	return 0

## Returns a randomly generated grid designed for map design
func get_new_grid() -> TileMap:
	var grid := TileMap.new()

	# RNG
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	# Variable room count
	var max_rooms := int(clamp(rng.randfn(16, 4), 12, 20))

	grid = generate_map(max_rooms, grid)
	grid = poke_holes(6, grid)

	return grid

func generate_map(max_rooms: int, grid: TileMap) -> TileMap:
	var cur_cell := Vector2.ZERO
	var DIR = [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]
	var room_cnt := 1 # Including starter room

	grid.set_cellv(cur_cell, START | VISITED)

	while room_cnt < max_rooms:
		DIR.shuffle()
		var new_room_cnt: int = randi() % 4 + 1

		for room in range(new_room_cnt):
			var next_room = DIR[room] + cur_cell

			if grid.get_cellv(next_room) == NOT_VISITED:
				grid.set_cellv(next_room, VISITED)
				room_cnt +=1

		cur_cell += DIR[0]

	return grid


# Pokes holes in the map
func poke_holes(tres: int, grid: TileMap) -> TileMap:
	for cell in grid.get_used_cells():
		if get_neighbor_cnt(cell, grid) > tres \
				and not grid.get_cellv(cell) & START:
			grid.set_cellv(cell, NOT_VISITED)

	return grid

## Returns an integer of neighboring tiles in a tilemap
func get_neighbor_cnt(cur_cell: Vector2, grid: TileMap) -> int:
	var DIR := [-1, 0, 1]
	var neigh_cnt := 0

	for cellx in DIR:
		for celly in DIR:
			var test_cell := cur_cell + Vector2(cellx, celly)

			if grid.get_cellv(test_cell) != NOT_VISITED:
				neigh_cnt += 1

	return neigh_cnt - 1 # Minus the cell itself
