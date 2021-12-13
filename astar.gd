extends Node

var _astar = AStar2D.new()
var _pos_to_point := {}
var _grid: TileMap

## Overrides the current astar with a new config with the current grid
func setup(grid: TileMap) -> void:
	_grid = grid
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
		var pos: Vector2 = _astar.get_point_position(point)
		for dir in Floor.find_neighboring_cells_dir(pos):
			var neigh = pos + dir
			_astar.connect_points(point, _pos_to_point[neigh])



func get_furthest_room_from_start() -> Vector2:
	var furthest_path: PoolVector2Array

	var used_cells = _grid.get_used_cells()
	used_cells.shuffle() # Shuffle to randomize boss room pos furthermore
	for cell in used_cells:
		var point = _pos_to_point[cell]

		var path: PoolVector2Array = _astar.get_point_path(point, _pos_to_point[Floor.START_CELL])
		if path.size() > furthest_path.size():
			furthest_path = path

	return furthest_path[0]
