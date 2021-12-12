extends Node
class_name Collectible

enum STATE {IDLE, HELD, USED}
enum RARITY {COMMON, UNCOMMON, RARE}
enum TYPE {HEART, CARROT}
enum HEART {BLUE, BOOM, POISON, SHEEP}
enum CARROT {VORTEX, INK, JUICY, SHEEP}

var _ui_sprite = Sprite.new()
var _map_sprite = Sprite.new()

var _rarity: int
var _state: int
var _type: int
var _effects := {
	"idle": null,
	"take": null,
	"damage": null,
	"use": null,
}


func get_effect(effect: String) -> Object:
	return _effects[effect]

func _init(
	map_texture: Texture,
	ui_texture: Texture,
	rarity: int,
	state: int,
	type: int,
	effect_idle: Object,
	effect_take: Object,
	effect_damage: Object,
	effect_use: Object
	):

	_ui_sprite.texture = ui_texture
	_map_sprite.texture = map_texture
	add_child(_ui_sprite)
	add_child(_map_sprite)

	_rarity = rarity
	_state = state
	_type = type
	
	_effects["idle"] = effect_idle
	_effects["take"] = effect_take
	_effects["damage"] = effect_damage
	_effects["use"] = effect_use

func show_map() -> void:
	_map_sprite.show()
	_ui_sprite.hide()

func show_ui() -> void:
	_map_sprite.show()
	_ui_sprite.hide()
