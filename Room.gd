extends Node2D

enum DOOR {UP = 0b1, RIGHT = 0b10, DOWN = 0b100, LEFT = 0b1000}

var path
export(int, FLAGS, "Up", "Right", "Down", "Left") var neighbors

onready var main: Node = get_tree().get_root().get_node("/root/Main")

func _ready():
	$Timer.autostart = true

func _on_Timer_timeout():
	var player: Node
	for enemy in get_tree().get_nodes_in_group("enemies"):
		player = get_tree().get_nodes_in_group("player")[0]

		path = $Navigation2D.get_simple_path(enemy.position, player.position)
		enemy.path = path

func _convert_door_flag_to_vec(flag: int) -> Vector2:
	var vec: Vector2

	match flag:
		DOOR.UP:
			vec = Vector2.UP
		DOOR.RIGHT:
			vec = Vector2.RIGHT
		DOOR.DOWN:
			vec = Vector2.DOWN
		DOOR.LEFT:
			vec = Vector2.LEFT
		_:
			push_error("Door flag: " + String(flag) + " does not exist.")

	return vec

func change_room(dir: int):
	if neighbors & dir: # If room is neighboring
		var next_room := _convert_door_flag_to_vec(dir)
		main.change_room(next_room)

### Ugly, repetitive manual connection is required since the scene will emit the
### "ready" signal at every room change, thus making it impossible to retain the
### connections across room changes, causing a flickering effect. Sorry.

func _on_Up_body_entered(_body):
	$Doors/Up.disconnect("body_entered", self, "_on_Up_body_entered")
	change_room(DOOR.UP)

func _on_Right_body_entered(_body):
	$Doors/Right.disconnect("body_entered", self, "_on_Right_body_entered")
	change_room(DOOR.RIGHT)

func _on_Down_body_entered(_body):
	$Doors/Down.disconnect("body_entered", self, "_on_Down_body_entered")
	change_room(DOOR.DOWN)

func _on_Left_body_entered(_body):
	$Doors/Left.disconnect("body_entered", self, "_on_Left_body_entered")
	change_room(DOOR.LEFT)

func _on_body_exited(_body):
	if not $Doors/Up.is_connected("body_entered", self, "_on_Up_body_entered"):
	# warning-ignore:return_value_discarded
		$Doors/Up.connect("body_entered", self, "_on_Up_body_entered")
	if not $Doors/Right.is_connected("body_entered", self, "_on_Right_body_entered"):
	# warning-ignore:return_value_discarded
		$Doors/Right.connect("body_entered", self, "_on_Right_body_entered")
	if not $Doors/Down.is_connected("body_entered", self, "_on_Down_body_entered"):
	# warning-ignore:return_value_discarded
		$Doors/Down.connect("body_entered", self, "_on_Down_body_entered")
	if not $Doors/Left.is_connected("body_entered", self, "_on_Left_body_entered"):
	# warning-ignore:return_value_discarded
		$Doors/Left.connect("body_entered", self, "_on_Left_body_entered")

func _on_Room_ready():
	var exit_dir = main.prev_room_pos - main.cur_room_pos

	match exit_dir:
		Vector2.ZERO:
			$Player.position = $Spawns/ZERO.position
		Vector2.UP:
			$Player.position = $Spawns/UP.position
		Vector2.RIGHT:
			$Player.position = $Spawns/RIGHT.position
		Vector2.DOWN:
			$Player.position = $Spawns/DOWN.position
		Vector2.LEFT:
			$Player.position = $Spawns/LEFT.position
		_:
			assert("Wrong direction.")
