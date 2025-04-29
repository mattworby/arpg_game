extends Node

const NORMAL_COLOR = Color.WHITE
const MAGIC_COLOR = Color(0.6, 0.6, 1.0)
const RARE_COLOR = Color(1.0, 1.0, 0.6)

const SLOT_HEAD = 0
const SLOT_BODY = 1
const SLOT_WEAPON = 2
const SLOT_SHIELD = 3
const SLOT_GLOVES = 4
const SLOT_BELT = 5
const SLOT_BOOTS = 6
const SLOT_AMULET = 7
const SLOT_RING_1 = 8
const SLOT_RING_2 = 9

var base_items = {
	# --- WEAPONS ---
	"short_sword": {
		"name": "Short Sword", "type": "weapon", "subtype": "sword", "grid_size": Vector2(1, 3),
		"valid_slots": [SLOT_WEAPON, SLOT_SHIELD], "texture": "res://assets/items/short_sword.png",
		"base_stats": {"damage_min": 3, "damage_max": 7, "attack_speed": 1.2},
		"level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"hand_axe": {
		"name": "Hand Axe", "type": "weapon", "subtype": "axe", "grid_size": Vector2(2, 3),
		"valid_slots": [SLOT_WEAPON], "texture": "res://assets/items/hand_axe.png",
		"base_stats": {"damage_min": 4, "damage_max": 9, "attack_speed": 1.0},
		"level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"large_axe": {
		"name": "Large Axe", "type": "weapon", "subtype": "axe", "grid_size": Vector2(2, 3),
		"valid_slots": [SLOT_WEAPON], "texture": "res://assets/items/large_axe.png",
		"base_stats": {"damage_min": 8, "damage_max": 15, "attack_speed": 0.8},
		"level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"short_bow": {
		"name": "Short Bow", "type": "weapon", "subtype": "bow", "grid_size": Vector2(2, 3),
		"valid_slots": [SLOT_WEAPON], "texture": "res://assets/items/short_bow.png",
		"base_stats": {"damage_min": 2, "damage_max": 5, "attack_speed": 1.5},
		"level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},

	# --- ARMOR: HELMETS ---
	"leather_cap": {
		"name": "Leather Cap", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_HEAD], "texture": "res://assets/items/leather_cap.png",
		"base_stats": {"defense": 3}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"horned_helmet": {
		"name": "Horned Helmet", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_HEAD], "texture": "res://assets/items/horned_helmet.png",
		"base_stats": {"defense": 8}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},

	# --- ARMOR: BODY ARMOR ---
	"leather_armor": {
		"name": "Leather Armor", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3),
		"valid_slots": [SLOT_BODY], "texture": "res://assets/items/leather_armor.png",
		"base_stats": {"defense": 12}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"chainmail": {
		"name": "Chainmail", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3),
		"valid_slots": [SLOT_BODY], "texture": "res://assets/items/chainmail.png",
		"base_stats": {"defense": 25}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},

	# --- ARMOR: GLOVES (NEW STRUCTURE) ---
	# Strength Based (Defense)
	"str_gloves_t1": {
		"name": "Rough Leather Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_str_t1.png",
		"base_stats": {"defense": 5}, "level_req": 1, "stat_req": {"strength": 5, "dexterity": 0, "wisdom": 0}
	},
	"str_gloves_t2": {
		"name": "Iron Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_str_t2.png",
		"base_stats": {"defense": 15}, "level_req": 20, "stat_req": {"strength": 25, "dexterity": 0, "wisdom": 0}
	},
	"str_gloves_t3": {
		"name": "Steel Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_str_t3.png",
		"base_stats": {"defense": 35}, "level_req": 40, "stat_req": {"strength": 50, "dexterity": 0, "wisdom": 0}
	},
	"str_gloves_t4": {
		"name": "Plate Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_str_t4.png",
		"base_stats": {"defense": 70}, "level_req": 60, "stat_req": {"strength": 85, "dexterity": 0, "wisdom": 0}
	},
	"str_gloves_t5": {
		"name": "Colossus Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_str_t5.png",
		"base_stats": {"defense": 120}, "level_req": 80, "stat_req": {"strength": 130, "dexterity": 0, "wisdom": 0}
	},
	# Dexterity Based (Evasion)
	"dex_gloves_t1": {
		"name": "Cloth Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dex_t1.png",
		"base_stats": {"evasion": 5}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 5, "wisdom": 0}
	},
	"dex_gloves_t2": {
		"name": "Silk Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dex_t2.png",
		"base_stats": {"evasion": 15}, "level_req": 20, "stat_req": {"strength": 0, "dexterity": 25, "wisdom": 0}
	},
	"dex_gloves_t3": {
		"name": "Velvet Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dex_t3.png",
		"base_stats": {"evasion": 35}, "level_req": 40, "stat_req": {"strength": 0, "dexterity": 50, "wisdom": 0}
	},
	"dex_gloves_t4": {
		"name": "Shadow Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dex_t4.png",
		"base_stats": {"evasion": 70}, "level_req": 60, "stat_req": {"strength": 0, "dexterity": 85, "wisdom": 0}
	},
	"dex_gloves_t5": {
		"name": "Assassin's Mitts", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dex_t5.png",
		"base_stats": {"evasion": 120}, "level_req": 80, "stat_req": {"strength": 0, "dexterity": 130, "wisdom": 0}
	},
	# Wisdom Based (Mana)
	"wis_gloves_t1": {
		"name": "Wraps", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_wis_t1.png",
		"base_stats": {"mana": 10}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 5}
	},
	"wis_gloves_t2": {
		"name": "Embroidered Mitts", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_wis_t2.png",
		"base_stats": {"mana": 25}, "level_req": 20, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 25}
	},
	"wis_gloves_t3": {
		"name": "Conjurer Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_wis_t3.png",
		"base_stats": {"mana": 50}, "level_req": 40, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 50}
	},
	"wis_gloves_t4": {
		"name": "Archmage Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_wis_t4.png",
		"base_stats": {"mana": 80}, "level_req": 60, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 85}
	},
	"wis_gloves_t5": {
		"name": "Oracle's Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_wis_t5.png",
		"base_stats": {"mana": 110}, "level_req": 80, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 130}
	},
	# Strength/Dexterity Hybrid (Defense/Evasion)
	"str_dex_gloves_t1": {
		"name": "Reinforced Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdex_t1.png",
		"base_stats": {"defense": 3, "evasion": 3}, "level_req": 1, "stat_req": {"strength": 3, "dexterity": 3, "wisdom": 0}
	},
	"str_dex_gloves_t2": {
		"name": "Scale Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdex_t2.png",
		"base_stats": {"defense": 8, "evasion": 8}, "level_req": 20, "stat_req": {"strength": 15, "dexterity": 15, "wisdom": 0}
	},
	"str_dex_gloves_t3": {
		"name": "Brigandine Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdex_t3.png",
		"base_stats": {"defense": 18, "evasion": 18}, "level_req": 40, "stat_req": {"strength": 30, "dexterity": 30, "wisdom": 0}
	},
	"str_dex_gloves_t4": {
		"name": "Dragonscale Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdex_t4.png",
		"base_stats": {"defense": 35, "evasion": 35}, "level_req": 60, "stat_req": {"strength": 50, "dexterity": 50, "wisdom": 0}
	},
	"str_dex_gloves_t5": {
		"name": "Wyrmscale Mitts", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdex_t5.png",
		"base_stats": {"defense": 60, "evasion": 60}, "level_req": 80, "stat_req": {"strength": 80, "dexterity": 80, "wisdom": 0}
	},
	# Strength/Wisdom Hybrid (Defense/Mana)
	"str_wis_gloves_t1": {
		"name": "Infused Leather Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strwis_t1.png",
		"base_stats": {"defense": 3, "mana": 5}, "level_req": 1, "stat_req": {"strength": 3, "dexterity": 0, "wisdom": 3}
	},
	"str_wis_gloves_t2": {
		"name": "Runed Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strwis_t2.png",
		"base_stats": {"defense": 8, "mana": 13}, "level_req": 20, "stat_req": {"strength": 15, "dexterity": 0, "wisdom": 15}
	},
	"str_wis_gloves_t3": {
		"name": "Zealot Mitts", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strwis_t3.png",
		"base_stats": {"defense": 18, "mana": 25}, "level_req": 40, "stat_req": {"strength": 30, "dexterity": 0, "wisdom": 30}
	},
	"str_wis_gloves_t4": {
		"name": "Templar Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strwis_t4.png",
		"base_stats": {"defense": 35, "mana": 40}, "level_req": 60, "stat_req": {"strength": 50, "dexterity": 0, "wisdom": 50}
	},
	"str_wis_gloves_t5": {
		"name": "Crusader Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strwis_t5.png",
		"base_stats": {"defense": 60, "mana": 55}, "level_req": 80, "stat_req": {"strength": 80, "dexterity": 0, "wisdom": 80}
	},
	# Dexterity/Wisdom Hybrid (Evasion/Mana)
	"dex_wis_gloves_t1": {
		"name": "Acolyte's Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dexwis_t1.png",
		"base_stats": {"evasion": 3, "mana": 5}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 3, "wisdom": 3}
	},
	"dex_wis_gloves_t2": {
		"name": "Sorcerer's Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dexwis_t2.png",
		"base_stats": {"evasion": 8, "mana": 13}, "level_req": 20, "stat_req": {"strength": 0, "dexterity": 15, "wisdom": 15}
	},
	"dex_wis_gloves_t3": {
		"name": "Arcanist Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dexwis_t3.png",
		"base_stats": {"evasion": 18, "mana": 25}, "level_req": 40, "stat_req": {"strength": 0, "dexterity": 30, "wisdom": 30}
	},
	"dex_wis_gloves_t4": {
		"name": "Illusionist Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dexwis_t4.png",
		"base_stats": {"evasion": 35, "mana": 40}, "level_req": 60, "stat_req": {"strength": 0, "dexterity": 50, "wisdom": 50}
	},
	"dex_wis_gloves_t5": {
		"name": "Mindspiral Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dexwis_t5.png",
		"base_stats": {"evasion": 60, "mana": 55}, "level_req": 80, "stat_req": {"strength": 0, "dexterity": 80, "wisdom": 80}
	},
	# Strength/Dexterity/Wisdom Hybrid (Defense/Evasion/Mana)
	"str_dex_wis_gloves_t1": {
		"name": "Traveler's Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdexwis_t1.png",
		"base_stats": {"defense": 2, "evasion": 2, "mana": 4}, "level_req": 1, "stat_req": {"strength": 2, "dexterity": 2, "wisdom": 2}
	},
	"str_dex_wis_gloves_t2": {
		"name": "Adventurer's Mitts", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdexwis_t2.png",
		"base_stats": {"defense": 5, "evasion": 5, "mana": 8}, "level_req": 20, "stat_req": {"strength": 10, "dexterity": 10, "wisdom": 10}
	},
	"str_dex_wis_gloves_t3": {
		"name": "Guardian Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdexwis_t3.png",
		"base_stats": {"defense": 12, "evasion": 12, "mana": 17}, "level_req": 40, "stat_req": {"strength": 20, "dexterity": 20, "wisdom": 20}
	},
	"str_dex_wis_gloves_t4": {
		"name": "Champion's Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdexwis_t4.png",
		"base_stats": {"defense": 24, "evasion": 24, "mana": 27}, "level_req": 60, "stat_req": {"strength": 35, "dexterity": 35, "wisdom": 35}
	},
	"str_dex_wis_gloves_t5": {
		"name": "Titan's Grip", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdexwis_t5.png",
		"base_stats": {"defense": 40, "evasion": 40, "mana": 37}, "level_req": 80, "stat_req": {"strength": 60, "dexterity": 60, "wisdom": 60}
	},

	# --- ARMOR: BOOTS ---
	"leather_boots": {
		"name": "Leather Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/leather_boots.png",
		"base_stats": {"defense": 2}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},

	# --- ARMOR: BELTS ---
	"leather_belt": {
		"name": "Leather Belt", "type": "armor", "subtype": "belt", "grid_size": Vector2(2, 1),
		"valid_slots": [SLOT_BELT], "texture": "res://assets/items/leather_belt.png",
		"base_stats": {"defense": 1}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},

	# --- SHIELDS ---
	"wooden_shield": {
		"name": "Wooden Shield", "type": "shield", "subtype": "shield", "grid_size": Vector2(2, 3),
		"valid_slots": [SLOT_SHIELD], "texture": "res://assets/items/wooden_shield.png",
		"base_stats": {"defense": 5, "block_chance": 10},
		"level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},

	# --- ACCESSORIES ---
	"gold_ring": {
		"name": "Gold Ring", "type": "accessory", "subtype": "ring", "grid_size": Vector2(1, 1),
		"valid_slots": [SLOT_RING_1, SLOT_RING_2], "texture": "res://assets/items/gold_ring.png",
		"base_stats": {}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"silver_amulet": {
		"name": "Silver Amulet", "type": "accessory", "subtype": "amulet", "grid_size": Vector2(1, 1),
		"valid_slots": [SLOT_AMULET], "texture": "res://assets/items/silver_amulet.png",
		"base_stats": {}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},

	# --- CONSUMABLES ---
	"health_potion": {
		"name": "Health Potion", "type": "consumable", "subtype": "potion", "grid_size": Vector2(1, 1),
		"valid_slots": [], "texture": "res://assets/items/health_potion.png",
		"base_stats": {"health_restore": 50}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"mana_potion": {
		"name": "Mana Potion", "type": "consumable", "subtype": "potion", "grid_size": Vector2(1, 1),
		"valid_slots": [], "texture": "res://assets/items/mana_potion.png",
		"base_stats": {"mana_restore": 50}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},

	# --- SCROLLS ---
	"scroll_of_identify": {
		"name": "Scroll of Identify", "type": "scroll", "subtype": "scroll", "grid_size": Vector2(1, 2),
		"valid_slots": [], "texture": "res://assets/items/scroll_identify.png",
		"base_stats": {}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
}

func get_base_item(item_id: String) -> Dictionary:
	if base_items.has(item_id):
		# Return a deep copy to prevent modification of the original data
		return base_items[item_id].duplicate(true)
	push_warning("Base item not found: " + item_id)
	return {}

func get_all_base_ids() -> Array:
	return base_items.keys()

func get_base_ids_by_subtype(subtype_name: String) -> Array:
	var matching_ids = []
	for item_id in base_items:
		if base_items[item_id].get("subtype") == subtype_name:
			matching_ids.append(item_id)
	return matching_ids

func get_base_ids_by_type(type_name: String) -> Array:
	var matching_ids = []
	for item_id in base_items:
		if base_items[item_id].get("type") == type_name:
			matching_ids.append(item_id)
	return matching_ids
