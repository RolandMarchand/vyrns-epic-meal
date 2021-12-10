extends "res://Character.gd"

const LOCAL_SPEED = 2 * SPEED # two cases per second

var path: PoolVector2Array

func _ready():
	health = 3

func _physics_process(_delta) -> void:
	if path and path.size() > 1:
		if position != path[1]:
			var p = path[1] - path[0] # Distance from 0 to 1
			p = p.clamped(1) # Converts path to a direction
			move_and_slide(p * LOCAL_SPEED / 3)
		else:
			path.remove(0)


func _on_Hitbox_area_entered(area) -> void:
	if area.owner.is_in_group("player"):
		var player = area.owner

		var knock_dir = player.position.direction_to(position).clamped(1)
		set_knockback(knock_dir)

		health -= player.damage
		if health < 1:
			queue_free()
