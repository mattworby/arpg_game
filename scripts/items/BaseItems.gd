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
	"short_sword": {
		"name": "Short Sword",
		"type": "weapon",
		"subtype": "sword",
		"grid_size": Vector2(1, 3),
		"valid_slots": [SLOT_WEAPON, SLOT_SHIELD],
		"texture": "res://assets/items/short_sword.png",
		"base_stats": {"damage_min": 3, "damage_max": 7, "attack_speed": 1.2},
		"level_req": 1,
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"hand_axe": {
		"name": "Hand Axe",
		"type": "weapon",
		"subtype": "axe",
		"grid_size": Vector2(2, 3),
		"valid_slots": [SLOT_WEAPON],
		"texture": "res://assets/items/hand_axe.png",
		"base_stats": {"damage_min": 4, "damage_max": 9, "attack_speed": 1.0},
		"level_req": 1,
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"large_axe": {
		"name": "Large Axe",
		"type": "weapon",
		"subtype": "axe",
		"grid_size": Vector2(2, 3),
		"valid_slots": [SLOT_WEAPON],
		"texture": "res://assets/items/large_axe.png",
		"base_stats": {"damage_min": 8, "damage_max": 15, "attack_speed": 0.8},
		"level_req": 1,
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"short_bow": {
		"name": "Short Bow",
		"type": "weapon",
		"subtype": "bow",
		"grid_size": Vector2(2, 3),
		"valid_slots": [SLOT_WEAPON],
		"texture": "res://assets/items/short_bow.png",
		"base_stats": {"damage_min": 2, "damage_max": 5, "attack_speed": 1.5},
		"level_req": 1,
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"leather_cap": {
		"name": "Leather Cap",
		"type": "armor",
		"subtype": "helmet",
		"grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_HEAD],
		"texture": "res://assets/items/leather_cap.png",
		"base_stats": {"defense": 3},
		"level_req": 1,
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"horned_helmet": {
		"name": "Horned Helmet",
		"type": "armor",
		"subtype": "helmet",
		"grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_HEAD],
		"texture": "res://assets/items/horned_helmet.png",
		"base_stats": {"defense": 8},
		"level_req": 1,
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"leather_armor": {
		"name": "Leather Armor",
		"type": "armor",
		"subtype": "body_armor",
		"grid_size": Vector2(2, 3),
		"valid_slots": [SLOT_BODY],
		"texture": "res://assets/items/leather_armor.png",
		"base_stats": {"defense": 12},
		"level_req": 1,
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"chainmail": {
		"name": "Chainmail",
		"type": "armor",
		"subtype": "body_armor",
		"grid_size": Vector2(2, 3),
		"valid_slots": [SLOT_BODY],
		"texture": "res://assets/items/chainmail.png",
		"base_stats": {"defense": 25},
		"level_req": 1,
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"leather_gloves": {
		"name": "Leather Gloves",
		"type": "armor",
		"subtype": "gloves",
		"grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_GLOVES],
		"texture": "res://assets/items/leather_gloves.png",
		"base_stats": {"defense": 2},
		"level_req": 1,
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"leather_boots": {
		"name": "Leather Boots",
		"type": "armor",
		"subtype": "boots",
		"grid_size": Vector2(2, 2),
		"valid_slots": [SLOT_BOOTS],
		"texture": "res://assets/items/leather_boots.png",
		"base_stats": {"defense": 2},
		"level_req": 1,
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"leather_belt": {
		"name": "Leather Belt",
		"type": "armor",
		"subtype": "belt",
		"grid_size": Vector2(2, 1),
		"valid_slots": [SLOT_BELT],
		"texture": "res://assets/items/leather_belt.png",
		"base_stats": {"defense": 1},
		"level_req": 1,
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},

	"wooden_shield": {
		"name": "Wooden Shield",
		"type": "shield",
		"subtype": "shield",
		"grid_size": Vector2(2, 3),
		"valid_slots": [SLOT_SHIELD],
		"texture": "res://assets/items/wooden_shield.png",
		"base_stats": {"defense": 5, "block_chance": 10},
		"level_req": 1, 
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
	"gold_ring": {
		"name": "Gold Ring",
		"type": "accessory",
		"subtype": "ring",
		"grid_size": Vector2(1, 1),
		"valid_slots": [SLOT_RING_1, SLOT_RING_2],
		"texture": "res://assets/items/gold_ring.png",
		"base_stats": {},
		"level_req": 1,
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0} 
	},
	"silver_amulet": {
		"name": "Silver Amulet",
		"type": "accessory",
		"subtype": "amulet",
		"grid_size": Vector2(1, 1),
		"valid_slots": [SLOT_AMULET],
		"texture": "res://assets/items/silver_amulet.png",
		"base_stats": {},
		"level_req": 1, 
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0} 
	},
	"health_potion": {
		"name": "Health Potion",
		"type": "consumable",
		"subtype": "potion",
		"grid_size": Vector2(1, 1),
		"valid_slots": [],
		"texture": "res://assets/items/health_potion.png",
		"base_stats": {"health_restore": 50},
		"level_req": 1,
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0} 
	},
	"mana_potion": {
		"name": "Mana Potion",
		"type": "consumable",
		"subtype": "potion",
		"grid_size": Vector2(1, 1),
		"valid_slots": [],
		"texture": "res://assets/items/mana_potion.png",
		"base_stats": {"mana_restore": 50},
		"level_req": 1,
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0} 
	},
	"scroll_of_identify": {
		"name": "Scroll of Identify",
		"type": "scroll",
		"subtype": "scroll",
		"grid_size": Vector2(1, 2),
		"valid_slots": [],
		"texture": "res://assets/items/scroll_identify.png",
		"base_stats": {},
		"level_req": 1,
		"stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},
}

func get_base_item(item_id: String) -> Dictionary:
	if base_items.has(item_id):
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
