extends KinematicBody2D

const MIN_KNOCKBACK := Vector2(10,10)
const KNOCKBACK_FORCE := 150
const KNOCKBACK_TIME := 0.4

const SPEED := 32 # 1 unit/sec
const RANGE := 16
const MAX_HEALTH := 16
const BASE_DAMAGE := 1


onready var sprite = $Sprite
onready var tween = $Tween
onready var anim_player = $AnimationPlayer
onready var attack_area = $AttackArea
onready var attack_shape = $AttackArea/CollisionShape2D

var health
var damage

var hurt := false
var dir := Vector2.ZERO
var last_dir := dir
var anim: String = "idle"
var knockback: Vector2 = Vector2.ZERO
export(bool) var can_attack: bool = true

func knockback(dir: Vector2) -> void:
	knockback = dir * KNOCKBACK_FORCE
	tween.interpolate_property(self, "knockback", knockback, Vector2.ZERO, KNOCKBACK_TIME, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

func _physics_process(delta) -> void:
	if knockback.length() > MIN_KNOCKBACK.length(): # knockback reduces in func knockback()
		move_and_slide(knockback)

	#set_anim()

	#$Animationlayer.play(anim)

## Unused as of now
func set_anim() -> void:
	match dir:
		Vector2.LEFT:
			sprite.flip_h = true
		Vector2.RIGHT:
			sprite.flip_h = false

	if dir != Vector2.ZERO:
		anim = "walk"
	else:
		anim = "idle"

func attack():
	can_attack = false

	attack_area.rotation = last_dir.angle()

	attack_shape.disabled = false
	$AttackTimer.start()


func _on_AttackTimer_timeout():
	can_attack = true

	attack_shape.disabled = true
