extends Node2D

enum DOOR {UP = 0b1, RIGHT = 0b10, DOWN = 0b100, LEFT = 0b1000}

var path
export(int, FLAGS, "Up", "Right", "Down", "Left") var neighbors

func _ready():
	$Timer.autostart = true

func _on_Timer_timeout():
	var player: Node
	for enemy in get_tree().get_nodes_in_group("enemies"):
		player = get_tree().get_nodes_in_group("player")[0]

		path = $Navigation2D.get_simple_path(enemy.position, player.position)
		enemy.path = path


func change_room(DOOR: int):
	if neighbors & DOOR:
		Save.save_room(name)
		#Save.load_room()


func _on_Up_body_entered(body):
	change_room(DOOR.UP)

func _on_Right_body_entered(body):
	change_room(DOOR.RIGHT)

func _on_Down_body_entered(body):
	change_room(DOOR.DOWN)

func _on_Left_body_entered(body):
	change_room(DOOR.LEFT)
