extends Node

var prefixes = {
	"sturdy": {
		"name": "Sturdy",
		"level_req": 1,
		"weight": 100,
		"stats": {"defense_flat": [3, 7]},
		"allowed_types": ["armor", "shield"]
	},
	"strong": {
		"name": "Strong",
		"level_req": 5,
		"weight": 80,
		"stats": {"defense_flat": [8, 12], "strength": [1, 2]},
		"allowed_types": ["armor", "shield", "belt"]
	},
	"blessed": {
		"name": "Blessed",
		"level_req": 10,
		"weight": 50,
		"stats": {"defense_percent": [3, 6]},
		"allowed_types": ["armor", "shield"]
	},
	"glowing": {
		"name": "Glowing",
		"level_req": 3,
		"weight": 70,
		"stats": {"light_radius": 1},
		"allowed_types": ["armor", "shield", "accessory"]
	},
	"sharp": {
		"name": "Sharp",
		"level_req": 1,
		"weight": 100,
		"stats": {"damage_flat": [1, 3]},
		"allowed_types": ["weapon"]
	},
	"deadly": {
		"name": "Deadly",
		"level_req": 8,
		"weight": 60,
		"stats": {"damage_flat": [4, 7], "attack_rating": [8, 15]},
		"allowed_types": ["weapon"]
	},
	"swift": {
		"name": "Swift",
		"level_req": 4,
		"weight": 70,
		"stats": {"attack_speed_percent": [4, 8]},
		"allowed_types": ["weapon", "gloves"]
	},
	"lucky": {
		"name": "Lucky",
		"level_req": 2,
		"weight": 90,
		"stats": {"magic_find": [2, 5]},
		"allowed_types": ["accessory"]
	},
}

var suffixes = {
	"of_health": {
		"name": "of Health",
		"level_req": 1,
		"weight": 100,
		"stats": {"health": [7, 15]},
		"allowed_types": ["armor", "shield", "accessory", "belt"]
	},
	"of_protection": {
		"name": "of Protection",
		"level_req": 3,
		"weight": 90,
		"stats": {"defense_flat": [2, 5]},
		"allowed_types": ["armor", "shield"]
	},
	"of_regeneration": {
		"name": "of Regeneration",
		"level_req": 12,
		"weight": 40,
		"stats": {"health_regen": 1},
		"allowed_types": ["armor", "shield", "accessory"]
	},
	"of_nimbleness": {
		"name": "of Nimbleness",
		"level_req": 5,
		"weight": 70,
		"stats": {"movement_speed": [3, 7]},
		"allowed_types": ["boots"]
	},
	"of_haste": {
		"name": "of Haste",
		"level_req": 6,
		"weight": 70,
		"stats": {"attack_speed_percent": [6, 10]},
		"allowed_types": ["weapon"]
	},
	"of_vampirism": {
		"name": "of Vampirism",
		"level_req": 15,
		"weight": 30,
		"stats": {"life_leech_percent": [2, 4]},
		"allowed_types": ["weapon"]
	},
	"of_the_apprentice": {
		"name": "of the Apprentice",
		"level_req": 5,
		"weight": 80,
		"stats": {"mana": [10, 20]},
		"allowed_types": ["accessory", "armor"]
	},
	"of_brilliance": {
		"name": "of Brilliance",
		"level_req": 9,
		"weight": 60,
		# Fixed value example
		"stats": {"mana_regen": 1},
		"allowed_types": ["accessory"]
	},
}

func get_compatible_affixes(base_item_data: Dictionary, affix_type: String, item_level: int = 1) -> Array:
	var compatible_affixes = []
	var affix_pool = prefixes if affix_type == "prefix" else suffixes
	var item_type = base_item_data.get("type", "")
	var item_subtype = base_item_data.get("subtype", "")

	for affix_id in affix_pool:
		var affix_data = affix_pool[affix_id]
		if affix_data.get("level_req", 1) > item_level:
			continue

		var allowed = affix_data.get("allowed_types", [])
		if item_type in allowed or item_subtype in allowed or "all" in allowed:
			compatible_affixes.append(affix_id)

	return compatible_affixes

func select_weighted_random_affixes(pool: Dictionary, count: int) -> Array:
	if pool.is_empty() or count <= 0:
		return []

	var selected_affixes = []
	var available_affixes = pool.duplicate()

	for _i in range(min(count, available_affixes.size())):
		var total_weight = 0
		for affix_id in available_affixes:
			total_weight += available_affixes[affix_id].get("weight", 1)

		if total_weight <= 0: break

		var random_roll = randf() * total_weight
		var current_weight = 0.0

		var chosen_id = null
		for affix_id in available_affixes:
			current_weight += available_affixes[affix_id].get("weight", 1)
			if random_roll <= current_weight:
				chosen_id = affix_id
				break

		if chosen_id != null:
			selected_affixes.append(chosen_id)
			available_affixes.erase(chosen_id)
		else:
			push_warning("Weighted random selection failed unexpectedly.")
			break

	return selected_affixes
