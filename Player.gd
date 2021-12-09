extends "res://Character.gd"


const LOCAL_SPEED = 2 * SPEED # 5 units/second



func oh_no():
	print("nonono")

func _ready():
	health = 3
	damage = BASE_DAMAGE

func _unhandled_key_input(event):
	if Input.is_action_just_pressed("ui_accept") and can_attack:
		attack()

func _physics_process(delta) -> void:
	set_dir()
	move_and_slide(dir.normalized() * LOCAL_SPEED)

func set_dir() -> void:
	if dir != Vector2.ZERO:
		last_dir = dir

	dir.x = Input.get_action_strength("ui_right") -\
			Input.get_action_strength("ui_left")
	dir.y = Input.get_action_strength("ui_down") -\
			Input.get_action_strength("ui_up")
