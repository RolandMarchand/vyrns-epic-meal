extends Node

enum {
	BLUE_HEART,
	BOOM_HEART,
	POISON_HEART,
	SHEEP_HEART,
	VORTEX_CARROT,
	INK_CARROT,
	JUICY_CARROT,
	SHEEP_CARROT
}

## TODO, add all other collectibles
func get_insance(collectible: int) -> Object:
	var map_texture: Texture
	var ui_texture: Texture
	var rarity: int
	var state: int
	var type: int
	var effect_idle: Object
	var effect_take: Object
	var effect_damage: Object
	var effect_use: Object
	
	match collectible:
		BLUE_HEART:
			map_texture = preload("res://icon.png")
			ui_texture = preload("res://icon.png")
			rarity = 0
			state = Collectible.STATE.IDLE
			type = Collectible.TYPE.HEART
			effect_idle = null
			effect_take = null
			effect_damage = null
			effect_use = null
		BOOM_HEART:
			pass
		POISON_HEART:
			pass
		SHEEP_HEART:
			pass
		VORTEX_CARROT:
			pass
		INK_CARROT:
			pass
		JUICY_CARROT:
			pass
		SHEEP_CARROT:
			pass
		_:
			assert("Collectible of type " + str(collectible) + " does not exist.")
	
	return Collectible.new(
		map_texture,
		ui_texture,
		rarity,
		state,
		type,
		effect_idle,
		effect_take,
		effect_damage,
		effect_use
	)
