# --- START OF FILE BaseItems.txt ---

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
	# (Keep existing weapon entries)
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

	# --- ARMOR: HELMETS (NEW STRUCTURE) ---
	# Strength Based (Defense)
	"str_helm_t1": { "name": "Leather Cap", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_str_t1.png", "base_stats": {"defense": 8}, "level_req": 1, "stat_req": {"strength": 8, "dexterity": 0, "wisdom": 0} },
	"str_helm_t2": { "name": "Iron Helm", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_str_t2.png", "base_stats": {"defense": 22}, "level_req": 20, "stat_req": {"strength": 30, "dexterity": 0, "wisdom": 0} },
	"str_helm_t3": { "name": "Steel Helm", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_str_t3.png", "base_stats": {"defense": 50}, "level_req": 40, "stat_req": {"strength": 60, "dexterity": 0, "wisdom": 0} },
	"str_helm_t4": { "name": "Great Helm", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_str_t4.png", "base_stats": {"defense": 95}, "level_req": 60, "stat_req": {"strength": 100, "dexterity": 0, "wisdom": 0} },
	"str_helm_t5": { "name": "Giant Helm", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_str_t5.png", "base_stats": {"defense": 160}, "level_req": 80, "stat_req": {"strength": 150, "dexterity": 0, "wisdom": 0} },
	# Dexterity Based (Evasion)
	"dex_helm_t1": { "name": "Skull Cap", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_dex_t1.png", "base_stats": {"evasion": 8}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 8, "wisdom": 0} },
	"dex_helm_t2": { "name": "Hood", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_dex_t2.png", "base_stats": {"evasion": 22}, "level_req": 20, "stat_req": {"strength": 0, "dexterity": 30, "wisdom": 0} },
	"dex_helm_t3": { "name": "Circlet", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_dex_t3.png", "base_stats": {"evasion": 50}, "level_req": 40, "stat_req": {"strength": 0, "dexterity": 60, "wisdom": 0} },
	"dex_helm_t4": { "name": "Mask", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_dex_t4.png", "base_stats": {"evasion": 95}, "level_req": 60, "stat_req": {"strength": 0, "dexterity": 100, "wisdom": 0} },
	"dex_helm_t5": { "name": "Diadem", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_dex_t5.png", "base_stats": {"evasion": 160}, "level_req": 80, "stat_req": {"strength": 0, "dexterity": 150, "wisdom": 0} },
	# Wisdom Based (Mana)
	"wis_helm_t1": { "name": "Bonnet", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_wis_t1.png", "base_stats": {"mana": 15}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 8} },
	"wis_helm_t2": { "name": "Crown", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_wis_t2.png", "base_stats": {"mana": 35}, "level_req": 20, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 30} },
	"wis_helm_t3": { "name": "Tiara", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_wis_t3.png", "base_stats": {"mana": 65}, "level_req": 40, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 60} },
	"wis_helm_t4": { "name": "Spirit Mask", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_wis_t4.png", "base_stats": {"mana": 100}, "level_req": 60, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 100} },
	"wis_helm_t5": { "name": "Prophet Crown", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_wis_t5.png", "base_stats": {"mana": 140}, "level_req": 80, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 150} },
	# Str/Dex Hybrid (Defense/Evasion)
	"str_dex_helm_t1": { "name": "Studded Cap", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_strdex_t1.png", "base_stats": {"defense": 4, "evasion": 4}, "level_req": 1, "stat_req": {"strength": 5, "dexterity": 5, "wisdom": 0} },
	"str_dex_helm_t2": { "name": "Horned Helm", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_strdex_t2.png", "base_stats": {"defense": 12, "evasion": 12}, "level_req": 20, "stat_req": {"strength": 18, "dexterity": 18, "wisdom": 0} },
	"str_dex_helm_t3": { "name": "Barbed Helm", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_strdex_t3.png", "base_stats": {"defense": 25, "evasion": 25}, "level_req": 40, "stat_req": {"strength": 40, "dexterity": 40, "wisdom": 0} },
	"str_dex_helm_t4": { "name": "Slayer Guard", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_strdex_t4.png", "base_stats": {"defense": 48, "evasion": 48}, "level_req": 60, "stat_req": {"strength": 65, "dexterity": 65, "wisdom": 0} },
	"str_dex_helm_t5": { "name": "Bone Visage", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_strdex_t5.png", "base_stats": {"defense": 80, "evasion": 80}, "level_req": 80, "stat_req": {"strength": 100, "dexterity": 100, "wisdom": 0} },
	# Str/Wis Hybrid (Defense/Mana)
	"str_wis_helm_t1": { "name": "War Cap", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_strwis_t1.png", "base_stats": {"defense": 4, "mana": 8}, "level_req": 1, "stat_req": {"strength": 5, "dexterity": 0, "wisdom": 5} },
	"str_wis_helm_t2": { "name": "Sallet", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_strwis_t2.png", "base_stats": {"defense": 12, "mana": 18}, "level_req": 20, "stat_req": {"strength": 18, "dexterity": 0, "wisdom": 18} },
	"str_wis_helm_t3": { "name": "Casque", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_strwis_t3.png", "base_stats": {"defense": 25, "mana": 33}, "level_req": 40, "stat_req": {"strength": 40, "dexterity": 0, "wisdom": 40} },
	"str_wis_helm_t4": { "name": "Basinet", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_strwis_t4.png", "base_stats": {"defense": 48, "mana": 50}, "level_req": 60, "stat_req": {"strength": 65, "dexterity": 0, "wisdom": 65} },
	"str_wis_helm_t5": { "name": "Armet", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_strwis_t5.png", "base_stats": {"defense": 80, "mana": 70}, "level_req": 80, "stat_req": {"strength": 100, "dexterity": 0, "wisdom": 100} },
	# Dex/Wis Hybrid (Evasion/Mana)
	"dex_wis_helm_t1": { "name": "Fanged Mask", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_dexwis_t1.png", "base_stats": {"evasion": 4, "mana": 8}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 5, "wisdom": 5} },
	"dex_wis_helm_t2": { "name": "Lion Helm", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_dexwis_t2.png", "base_stats": {"evasion": 12, "mana": 18}, "level_req": 20, "stat_req": {"strength": 0, "dexterity": 18, "wisdom": 18} },
	"dex_wis_helm_t3": { "name": "Rage Mask", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_dexwis_t3.png", "base_stats": {"evasion": 25, "mana": 33}, "level_req": 40, "stat_req": {"strength": 0, "dexterity": 40, "wisdom": 40} },
	"dex_wis_helm_t4": { "name": "Savage Helmet", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_dexwis_t4.png", "base_stats": {"evasion": 48, "mana": 50}, "level_req": 60, "stat_req": {"strength": 0, "dexterity": 65, "wisdom": 65} },
	"dex_wis_helm_t5": { "name": "Coronet", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_dexwis_t5.png", "base_stats": {"evasion": 80, "mana": 70}, "level_req": 80, "stat_req": {"strength": 0, "dexterity": 100, "wisdom": 100} },
	# Str/Dex/Wis Hybrid (Defense/Evasion/Mana)
	"str_dex_wis_helm_t1": { "name": "Tribal Helm", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_strdexwis_t1.png", "base_stats": {"defense": 3, "evasion": 3, "mana": 5}, "level_req": 1, "stat_req": {"strength": 3, "dexterity": 3, "wisdom": 3} },
	"str_dex_wis_helm_t2": { "name": "Shaman Helm", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_strdexwis_t2.png", "base_stats": {"defense": 8, "evasion": 8, "mana": 12}, "level_req": 20, "stat_req": {"strength": 12, "dexterity": 12, "wisdom": 12} },
	"str_dex_wis_helm_t3": { "name": "Elder Helm", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_strdexwis_t3.png", "base_stats": {"defense": 17, "evasion": 17, "mana": 22}, "level_req": 40, "stat_req": {"strength": 25, "dexterity": 25, "wisdom": 25} },
	"str_dex_wis_helm_t4": { "name": "Sacred Helm", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_strdexwis_t4.png", "base_stats": {"defense": 32, "evasion": 32, "mana": 34}, "level_req": 60, "stat_req": {"strength": 45, "dexterity": 45, "wisdom": 45} },
	"str_dex_wis_helm_t5": { "name": "Mythical Helm", "type": "armor", "subtype": "helmet", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_HEAD], "texture": "res://assets/items/helm_strdexwis_t5.png", "base_stats": {"defense": 54, "evasion": 54, "mana": 47}, "level_req": 80, "stat_req": {"strength": 70, "dexterity": 70, "wisdom": 70} },

	# --- ARMOR: BODY ARMOR (NEW STRUCTURE) ---
	# Strength Based (Defense) - Note: Higher defense values than other slots
	"str_body_t1": { "name": "Hard Leather Armor", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_str_t1.png", "base_stats": {"defense": 25}, "level_req": 1, "stat_req": {"strength": 15, "dexterity": 0, "wisdom": 0} },
	"str_body_t2": { "name": "Ring Mail", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_str_t2.png", "base_stats": {"defense": 60}, "level_req": 20, "stat_req": {"strength": 40, "dexterity": 0, "wisdom": 0} },
	"str_body_t3": { "name": "Scale Mail", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_str_t3.png", "base_stats": {"defense": 130}, "level_req": 40, "stat_req": {"strength": 75, "dexterity": 0, "wisdom": 0} },
	"str_body_t4": { "name": "Plate Mail", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_str_t4.png", "base_stats": {"defense": 250}, "level_req": 60, "stat_req": {"strength": 120, "dexterity": 0, "wisdom": 0} },
	"str_body_t5": { "name": "Ancient Armor", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_str_t5.png", "base_stats": {"defense": 400}, "level_req": 80, "stat_req": {"strength": 180, "dexterity": 0, "wisdom": 0} },
	# Dexterity Based (Evasion)
	"dex_body_t1": { "name": "Quilted Armor", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_dex_t1.png", "base_stats": {"evasion": 25}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 15, "wisdom": 0} },
	"dex_body_t2": { "name": "Leather Armor", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_dex_t2.png", "base_stats": {"evasion": 60}, "level_req": 20, "stat_req": {"strength": 0, "dexterity": 40, "wisdom": 0} },
	"dex_body_t3": { "name": "Studded Leather", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_dex_t3.png", "base_stats": {"evasion": 130}, "level_req": 40, "stat_req": {"strength": 0, "dexterity": 75, "wisdom": 0} },
	"dex_body_t4": { "name": "Trellised Armor", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_dex_t4.png", "base_stats": {"evasion": 250}, "level_req": 60, "stat_req": {"strength": 0, "dexterity": 120, "wisdom": 0} },
	"dex_body_t5": { "name": "Wyrmhide", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_dex_t5.png", "base_stats": {"evasion": 400}, "level_req": 80, "stat_req": {"strength": 0, "dexterity": 180, "wisdom": 0} },
	# Wisdom Based (Mana)
	"wis_body_t1": { "name": "Robes", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_wis_t1.png", "base_stats": {"mana": 30}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 15} },
	"wis_body_t2": { "name": "Mage Plate", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_wis_t2.png", "base_stats": {"mana": 70}, "level_req": 20, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 40} },
	"wis_body_t3": { "name": "Archon Plate", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_wis_t3.png", "base_stats": {"mana": 130}, "level_req": 40, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 75} },
	"wis_body_t4": { "name": "Dusk Shroud", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_wis_t4.png", "base_stats": {"mana": 200}, "level_req": 60, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 120} },
	"wis_body_t5": { "name": "Seraphim Robe", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_wis_t5.png", "base_stats": {"mana": 280}, "level_req": 80, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 180} },
	# Str/Dex Hybrid (Defense/Evasion)
	"str_dex_body_t1": { "name": "Splint Mail", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_strdex_t1.png", "base_stats": {"defense": 13, "evasion": 13}, "level_req": 1, "stat_req": {"strength": 10, "dexterity": 10, "wisdom": 0} },
	"str_dex_body_t2": { "name": "Field Plate", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_strdex_t2.png", "base_stats": {"defense": 30, "evasion": 30}, "level_req": 20, "stat_req": {"strength": 25, "dexterity": 25, "wisdom": 0} },
	"str_dex_body_t3": { "name": "Gothic Plate", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_strdex_t3.png", "base_stats": {"defense": 65, "evasion": 65}, "level_req": 40, "stat_req": {"strength": 50, "dexterity": 50, "wisdom": 0} },
	"str_dex_body_t4": { "name": "Chaos Armor", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_strdex_t4.png", "base_stats": {"defense": 125, "evasion": 125}, "level_req": 60, "stat_req": {"strength": 80, "dexterity": 80, "wisdom": 0} },
	"str_dex_body_t5": { "name": "Shadow Plate", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_strdex_t5.png", "base_stats": {"defense": 200, "evasion": 200}, "level_req": 80, "stat_req": {"strength": 120, "dexterity": 120, "wisdom": 0} },
	# Str/Wis Hybrid (Defense/Mana)
	"str_wis_body_t1": { "name": "Breast Plate", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_strwis_t1.png", "base_stats": {"defense": 13, "mana": 15}, "level_req": 1, "stat_req": {"strength": 10, "dexterity": 0, "wisdom": 10} },
	"str_wis_body_t2": { "name": "Light Plate", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_strwis_t2.png", "base_stats": {"defense": 30, "mana": 35}, "level_req": 20, "stat_req": {"strength": 25, "dexterity": 0, "wisdom": 25} },
	"str_wis_body_t3": { "name": "Ornate Plate", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_strwis_t3.png", "base_stats": {"defense": 65, "mana": 65}, "level_req": 40, "stat_req": {"strength": 50, "dexterity": 0, "wisdom": 50} },
	"str_wis_body_t4": { "name": "Embossed Plate", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_strwis_t4.png", "base_stats": {"defense": 125, "mana": 100}, "level_req": 60, "stat_req": {"strength": 80, "dexterity": 0, "wisdom": 80} },
	"str_wis_body_t5": { "name": "Sacred Armor", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_strwis_t5.png", "base_stats": {"defense": 200, "mana": 140}, "level_req": 80, "stat_req": {"strength": 120, "dexterity": 0, "wisdom": 120} },
	# Dex/Wis Hybrid (Evasion/Mana)
	"dex_wis_body_t1": { "name": "Ghost Armor", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_dexwis_t1.png", "base_stats": {"evasion": 13, "mana": 15}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 10, "wisdom": 10} },
	"dex_wis_body_t2": { "name": "Serpentskin Armor", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_dexwis_t2.png", "base_stats": {"evasion": 30, "mana": 35}, "level_req": 20, "stat_req": {"strength": 0, "dexterity": 25, "wisdom": 25} },
	"dex_wis_body_t3": { "name": "Demonhide Armor", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_dexwis_t3.png", "base_stats": {"evasion": 65, "mana": 65}, "level_req": 40, "stat_req": {"strength": 0, "dexterity": 50, "wisdom": 50} },
	"dex_wis_body_t4": { "name": "Scarab Husk", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_dexwis_t4.png", "base_stats": {"evasion": 125, "mana": 100}, "level_req": 60, "stat_req": {"strength": 0, "dexterity": 80, "wisdom": 80} },
	"dex_wis_body_t5": { "name": "Wire Fleece", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_dexwis_t5.png", "base_stats": {"evasion": 200, "mana": 140}, "level_req": 80, "stat_req": {"strength": 0, "dexterity": 120, "wisdom": 120} },
	# Str/Dex/Wis Hybrid (Defense/Evasion/Mana)
	"str_dex_wis_body_t1": { "name": "Chain Mail", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_strdexwis_t1.png", "base_stats": {"defense": 9, "evasion": 9, "mana": 10}, "level_req": 1, "stat_req": {"strength": 8, "dexterity": 8, "wisdom": 8} },
	"str_dex_wis_body_t2": { "name": "Cuirass", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_strdexwis_t2.png", "base_stats": {"defense": 20, "evasion": 20, "mana": 24}, "level_req": 20, "stat_req": {"strength": 18, "dexterity": 18, "wisdom": 18} },
	"str_dex_wis_body_t3": { "name": "Russet Armor", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_strdexwis_t3.png", "base_stats": {"defense": 44, "evasion": 44, "mana": 44}, "level_req": 40, "stat_req": {"strength": 35, "dexterity": 35, "wisdom": 35} },
	"str_dex_wis_body_t4": { "name": "Templar Coat", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_strdexwis_t4.png", "base_stats": {"defense": 84, "evasion": 84, "mana": 67}, "level_req": 60, "stat_req": {"strength": 55, "dexterity": 55, "wisdom": 55} },
	"str_dex_wis_body_t5": { "name": "Hellforge Plate", "type": "armor", "subtype": "body_armor", "grid_size": Vector2(2, 3), "valid_slots": [SLOT_BODY], "texture": "res://assets/items/body_strdexwis_t5.png", "base_stats": {"defense": 134, "evasion": 134, "mana": 94}, "level_req": 80, "stat_req": {"strength": 80, "dexterity": 80, "wisdom": 80} },

	# --- ARMOR: GLOVES ---
	# (Keep existing glove entries)
	# Strength Based (Defense)
	"str_gloves_t1": { "name": "Rough Leather Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_str_t1.png", "base_stats": {"defense": 5}, "level_req": 1, "stat_req": {"strength": 5, "dexterity": 0, "wisdom": 0} },
	"str_gloves_t2": { "name": "Iron Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_str_t2.png", "base_stats": {"defense": 15}, "level_req": 20, "stat_req": {"strength": 25, "dexterity": 0, "wisdom": 0} },
	"str_gloves_t3": { "name": "Steel Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_str_t3.png", "base_stats": {"defense": 35}, "level_req": 40, "stat_req": {"strength": 50, "dexterity": 0, "wisdom": 0} },
	"str_gloves_t4": { "name": "Plate Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_str_t4.png", "base_stats": {"defense": 70}, "level_req": 60, "stat_req": {"strength": 85, "dexterity": 0, "wisdom": 0} },
	"str_gloves_t5": { "name": "Colossus Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_str_t5.png", "base_stats": {"defense": 120}, "level_req": 80, "stat_req": {"strength": 130, "dexterity": 0, "wisdom": 0} },
	# Dexterity Based (Evasion)
	"dex_gloves_t1": { "name": "Cloth Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dex_t1.png", "base_stats": {"evasion": 5}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 5, "wisdom": 0} },
	"dex_gloves_t2": { "name": "Silk Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dex_t2.png", "base_stats": {"evasion": 15}, "level_req": 20, "stat_req": {"strength": 0, "dexterity": 25, "wisdom": 0} },
	"dex_gloves_t3": { "name": "Velvet Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dex_t3.png", "base_stats": {"evasion": 35}, "level_req": 40, "stat_req": {"strength": 0, "dexterity": 50, "wisdom": 0} },
	"dex_gloves_t4": { "name": "Shadow Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dex_t4.png", "base_stats": {"evasion": 70}, "level_req": 60, "stat_req": {"strength": 0, "dexterity": 85, "wisdom": 0} },
	"dex_gloves_t5": { "name": "Assassin's Mitts", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dex_t5.png", "base_stats": {"evasion": 120}, "level_req": 80, "stat_req": {"strength": 0, "dexterity": 130, "wisdom": 0} },
	# Wisdom Based (Mana)
	"wis_gloves_t1": { "name": "Wraps", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_wis_t1.png", "base_stats": {"mana": 10}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 5} },
	"wis_gloves_t2": { "name": "Embroidered Mitts", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_wis_t2.png", "base_stats": {"mana": 25}, "level_req": 20, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 25} },
	"wis_gloves_t3": { "name": "Conjurer Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_wis_t3.png", "base_stats": {"mana": 50}, "level_req": 40, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 50} },
	"wis_gloves_t4": { "name": "Archmage Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_wis_t4.png", "base_stats": {"mana": 80}, "level_req": 60, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 85} },
	"wis_gloves_t5": { "name": "Oracle's Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_wis_t5.png", "base_stats": {"mana": 110}, "level_req": 80, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 130} },
	# Strength/Dexterity Hybrid (Defense/Evasion)
	"str_dex_gloves_t1": { "name": "Reinforced Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdex_t1.png", "base_stats": {"defense": 3, "evasion": 3}, "level_req": 1, "stat_req": {"strength": 3, "dexterity": 3, "wisdom": 0} },
	"str_dex_gloves_t2": { "name": "Scale Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdex_t2.png", "base_stats": {"defense": 8, "evasion": 8}, "level_req": 20, "stat_req": {"strength": 15, "dexterity": 15, "wisdom": 0} },
	"str_dex_gloves_t3": { "name": "Brigandine Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdex_t3.png", "base_stats": {"defense": 18, "evasion": 18}, "level_req": 40, "stat_req": {"strength": 30, "dexterity": 30, "wisdom": 0} },
	"str_dex_gloves_t4": { "name": "Dragonscale Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdex_t4.png", "base_stats": {"defense": 35, "evasion": 35}, "level_req": 60, "stat_req": {"strength": 50, "dexterity": 50, "wisdom": 0} },
	"str_dex_gloves_t5": { "name": "Wyrmscale Mitts", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdex_t5.png", "base_stats": {"defense": 60, "evasion": 60}, "level_req": 80, "stat_req": {"strength": 80, "dexterity": 80, "wisdom": 0} },
	# Strength/Wisdom Hybrid (Defense/Mana)
	"str_wis_gloves_t1": { "name": "Infused Leather Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strwis_t1.png", "base_stats": {"defense": 3, "mana": 5}, "level_req": 1, "stat_req": {"strength": 3, "dexterity": 0, "wisdom": 3} },
	"str_wis_gloves_t2": { "name": "Runed Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strwis_t2.png", "base_stats": {"defense": 8, "mana": 13}, "level_req": 20, "stat_req": {"strength": 15, "dexterity": 0, "wisdom": 15} },
	"str_wis_gloves_t3": { "name": "Zealot Mitts", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strwis_t3.png", "base_stats": {"defense": 18, "mana": 25}, "level_req": 40, "stat_req": {"strength": 30, "dexterity": 0, "wisdom": 30} },
	"str_wis_gloves_t4": { "name": "Templar Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strwis_t4.png", "base_stats": {"defense": 35, "mana": 40}, "level_req": 60, "stat_req": {"strength": 50, "dexterity": 0, "wisdom": 50} },
	"str_wis_gloves_t5": { "name": "Crusader Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strwis_t5.png", "base_stats": {"defense": 60, "mana": 55}, "level_req": 80, "stat_req": {"strength": 80, "dexterity": 0, "wisdom": 80} },
	# Dexterity/Wisdom Hybrid (Evasion/Mana)
	"dex_wis_gloves_t1": { "name": "Acolyte's Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dexwis_t1.png", "base_stats": {"evasion": 3, "mana": 5}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 3, "wisdom": 3} },
	"dex_wis_gloves_t2": { "name": "Sorcerer's Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dexwis_t2.png", "base_stats": {"evasion": 8, "mana": 13}, "level_req": 20, "stat_req": {"strength": 0, "dexterity": 15, "wisdom": 15} },
	"dex_wis_gloves_t3": { "name": "Arcanist Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dexwis_t3.png", "base_stats": {"evasion": 18, "mana": 25}, "level_req": 40, "stat_req": {"strength": 0, "dexterity": 30, "wisdom": 30} },
	"dex_wis_gloves_t4": { "name": "Illusionist Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dexwis_t4.png", "base_stats": {"evasion": 35, "mana": 40}, "level_req": 60, "stat_req": {"strength": 0, "dexterity": 50, "wisdom": 50} },
	"dex_wis_gloves_t5": { "name": "Mindspiral Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_dexwis_t5.png", "base_stats": {"evasion": 60, "mana": 55}, "level_req": 80, "stat_req": {"strength": 0, "dexterity": 80, "wisdom": 80} },
	# Strength/Dexterity/Wisdom Hybrid (Defense/Evasion/Mana)
	"str_dex_wis_gloves_t1": { "name": "Traveler's Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdexwis_t1.png", "base_stats": {"defense": 2, "evasion": 2, "mana": 4}, "level_req": 1, "stat_req": {"strength": 2, "dexterity": 2, "wisdom": 2} },
	"str_dex_wis_gloves_t2": { "name": "Adventurer's Mitts", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdexwis_t2.png", "base_stats": {"defense": 5, "evasion": 5, "mana": 8}, "level_req": 20, "stat_req": {"strength": 10, "dexterity": 10, "wisdom": 10} },
	"str_dex_wis_gloves_t3": { "name": "Guardian Gloves", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdexwis_t3.png", "base_stats": {"defense": 12, "evasion": 12, "mana": 17}, "level_req": 40, "stat_req": {"strength": 20, "dexterity": 20, "wisdom": 20} },
	"str_dex_wis_gloves_t4": { "name": "Champion's Gauntlets", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdexwis_t4.png", "base_stats": {"defense": 24, "evasion": 24, "mana": 27}, "level_req": 60, "stat_req": {"strength": 35, "dexterity": 35, "wisdom": 35} },
	"str_dex_wis_gloves_t5": { "name": "Titan's Grip", "type": "armor", "subtype": "gloves", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_GLOVES], "texture": "res://assets/items/gloves_strdexwis_t5.png", "base_stats": {"defense": 40, "evasion": 40, "mana": 37}, "level_req": 80, "stat_req": {"strength": 60, "dexterity": 60, "wisdom": 60} },


	# --- ARMOR: BOOTS (NEW STRUCTURE) ---
	# Strength Based (Defense)
	"str_boots_t1": { "name": "Leather Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_str_t1.png", "base_stats": {"defense": 5}, "level_req": 1, "stat_req": {"strength": 5, "dexterity": 0, "wisdom": 0} },
	"str_boots_t2": { "name": "Chain Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_str_t2.png", "base_stats": {"defense": 15}, "level_req": 20, "stat_req": {"strength": 25, "dexterity": 0, "wisdom": 0} },
	"str_boots_t3": { "name": "Mesh Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_str_t3.png", "base_stats": {"defense": 35}, "level_req": 40, "stat_req": {"strength": 50, "dexterity": 0, "wisdom": 0} },
	"str_boots_t4": { "name": "Plate Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_str_t4.png", "base_stats": {"defense": 70}, "level_req": 60, "stat_req": {"strength": 85, "dexterity": 0, "wisdom": 0} },
	"str_boots_t5": { "name": "Greaves", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_str_t5.png", "base_stats": {"defense": 120}, "level_req": 80, "stat_req": {"strength": 130, "dexterity": 0, "wisdom": 0} },
	# Dexterity Based (Evasion)
	"dex_boots_t1": { "name": "Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_dex_t1.png", "base_stats": {"evasion": 5}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 5, "wisdom": 0} },
	"dex_boots_t2": { "name": "Heavy Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_dex_t2.png", "base_stats": {"evasion": 15}, "level_req": 20, "stat_req": {"strength": 0, "dexterity": 25, "wisdom": 0} },
	"dex_boots_t3": { "name": "Light Plated Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_dex_t3.png", "base_stats": {"evasion": 35}, "level_req": 40, "stat_req": {"strength": 0, "dexterity": 50, "wisdom": 0} },
	"dex_boots_t4": { "name": "Demonhide Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_dex_t4.png", "base_stats": {"evasion": 70}, "level_req": 60, "stat_req": {"strength": 0, "dexterity": 85, "wisdom": 0} },
	"dex_boots_t5": { "name": "Wyrmhide Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_dex_t5.png", "base_stats": {"evasion": 120}, "level_req": 80, "stat_req": {"strength": 0, "dexterity": 130, "wisdom": 0} },
	# Wisdom Based (Mana)
	"wis_boots_t1": { "name": "Shoes", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_wis_t1.png", "base_stats": {"mana": 10}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 5} },
	"wis_boots_t2": { "name": "Light Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_wis_t2.png", "base_stats": {"mana": 25}, "level_req": 20, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 25} },
	"wis_boots_t3": { "name": "Scarabshell Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_wis_t3.png", "base_stats": {"mana": 50}, "level_req": 40, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 50} },
	"wis_boots_t4": { "name": "Boneweave Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_wis_t4.png", "base_stats": {"mana": 80}, "level_req": 60, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 85} },
	"wis_boots_t5": { "name": "Mirrored Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_wis_t5.png", "base_stats": {"mana": 110}, "level_req": 80, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 130} },
	# Str/Dex Hybrid (Defense/Evasion)
	"str_dex_boots_t1": { "name": "Studded Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_strdex_t1.png", "base_stats": {"defense": 3, "evasion": 3}, "level_req": 1, "stat_req": {"strength": 3, "dexterity": 3, "wisdom": 0} },
	"str_dex_boots_t2": { "name": "Reinforced Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_strdex_t2.png", "base_stats": {"defense": 8, "evasion": 8}, "level_req": 20, "stat_req": {"strength": 15, "dexterity": 15, "wisdom": 0} },
	"str_dex_boots_t3": { "name": "Battle Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_strdex_t3.png", "base_stats": {"defense": 18, "evasion": 18}, "level_req": 40, "stat_req": {"strength": 30, "dexterity": 30, "wisdom": 0} },
	"str_dex_boots_t4": { "name": "War Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_strdex_t4.png", "base_stats": {"defense": 35, "evasion": 35}, "level_req": 60, "stat_req": {"strength": 50, "dexterity": 50, "wisdom": 0} },
	"str_dex_boots_t5": { "name": "Myrmidon Greaves", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_strdex_t5.png", "base_stats": {"defense": 60, "evasion": 60}, "level_req": 80, "stat_req": {"strength": 80, "dexterity": 80, "wisdom": 0} },
	# Str/Wis Hybrid (Defense/Mana)
	"str_wis_boots_t1": { "name": "Infused Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_strwis_t1.png", "base_stats": {"defense": 3, "mana": 5}, "level_req": 1, "stat_req": {"strength": 3, "dexterity": 0, "wisdom": 3} },
	"str_wis_boots_t2": { "name": "Plated Shoes", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_strwis_t2.png", "base_stats": {"defense": 8, "mana": 13}, "level_req": 20, "stat_req": {"strength": 15, "dexterity": 0, "wisdom": 15} },
	"str_wis_boots_t3": { "name": "Runic Greaves", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_strwis_t3.png", "base_stats": {"defense": 18, "mana": 25}, "level_req": 40, "stat_req": {"strength": 30, "dexterity": 0, "wisdom": 30} },
	"str_wis_boots_t4": { "name": "Golem Walkers", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_strwis_t4.png", "base_stats": {"defense": 35, "mana": 40}, "level_req": 60, "stat_req": {"strength": 50, "dexterity": 0, "wisdom": 50} },
	"str_wis_boots_t5": { "name": "Titan Treads", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_strwis_t5.png", "base_stats": {"defense": 60, "mana": 55}, "level_req": 80, "stat_req": {"strength": 80, "dexterity": 0, "wisdom": 80} },
	# Dex/Wis Hybrid (Evasion/Mana)
	"dex_wis_boots_t1": { "name": "Traveler Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_dexwis_t1.png", "base_stats": {"evasion": 3, "mana": 5}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 3, "wisdom": 3} },
	"dex_wis_boots_t2": { "name": "Silkweave Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_dexwis_t2.png", "base_stats": {"evasion": 8, "mana": 13}, "level_req": 20, "stat_req": {"strength": 0, "dexterity": 15, "wisdom": 15} },
	"dex_wis_boots_t3": { "name": "Whisperwalk Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_dexwis_t3.png", "base_stats": {"evasion": 18, "mana": 25}, "level_req": 40, "stat_req": {"strength": 0, "dexterity": 30, "wisdom": 30} },
	"dex_wis_boots_t4": { "name": "Shadow Dancers", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_dexwis_t4.png", "base_stats": {"evasion": 35, "mana": 40}, "level_req": 60, "stat_req": {"strength": 0, "dexterity": 50, "wisdom": 50} },
	"dex_wis_boots_t5": { "name": "Windstriders", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_dexwis_t5.png", "base_stats": {"evasion": 60, "mana": 55}, "level_req": 80, "stat_req": {"strength": 0, "dexterity": 80, "wisdom": 80} },
	# Str/Dex/Wis Hybrid (Defense/Evasion/Mana)
	"str_dex_wis_boots_t1": { "name": "Worn Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_strdexwis_t1.png", "base_stats": {"defense": 2, "evasion": 2, "mana": 4}, "level_req": 1, "stat_req": {"strength": 2, "dexterity": 2, "wisdom": 2} },
	"str_dex_wis_boots_t2": { "name": "Rugged Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_strdexwis_t2.png", "base_stats": {"defense": 5, "evasion": 5, "mana": 8}, "level_req": 20, "stat_req": {"strength": 10, "dexterity": 10, "wisdom": 10} },
	"str_dex_wis_boots_t3": { "name": "Expedition Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_strdexwis_t3.png", "base_stats": {"defense": 12, "evasion": 12, "mana": 17}, "level_req": 40, "stat_req": {"strength": 20, "dexterity": 20, "wisdom": 20} },
	"str_dex_wis_boots_t4": { "name": "Trailblazer Boots", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_strdexwis_t4.png", "base_stats": {"defense": 24, "evasion": 24, "mana": 27}, "level_req": 60, "stat_req": {"strength": 35, "dexterity": 35, "wisdom": 35} },
	"str_dex_wis_boots_t5": { "name": "Wayfarer's Treads", "type": "armor", "subtype": "boots", "grid_size": Vector2(2, 2), "valid_slots": [SLOT_BOOTS], "texture": "res://assets/items/boots_strdexwis_t5.png", "base_stats": {"defense": 40, "evasion": 40, "mana": 37}, "level_req": 80, "stat_req": {"strength": 60, "dexterity": 60, "wisdom": 60} },

	# --- ARMOR: BELTS ---
	# (Belts could also get this treatment, but keeping simple for now)
	"leather_belt": {
		"name": "Leather Belt", "type": "armor", "subtype": "belt", "grid_size": Vector2(2, 1),
		"valid_slots": [SLOT_BELT], "texture": "res://assets/items/leather_belt.png",
		"base_stats": {"defense": 1}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},

	# --- SHIELDS ---
	# (Shields could also get this treatment, but keeping simple for now)
	"wooden_shield": {
		"name": "Wooden Shield", "type": "shield", "subtype": "shield", "grid_size": Vector2(2, 3),
		"valid_slots": [SLOT_SHIELD], "texture": "res://assets/items/wooden_shield.png",
		"base_stats": {"defense": 5, "block_chance": 10},
		"level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0}
	},

	# --- ACCESSORIES ---
	# (Accessories typically don't have base stats/reqs, but could be expanded later)
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
	# (Keep existing consumables)
	"health_potion": { "name": "Health Potion", "type": "consumable", "subtype": "potion", "grid_size": Vector2(1, 1), "valid_slots": [], "texture": "res://assets/items/health_potion.png", "base_stats": {"health_restore": 50}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0} },
	"mana_potion": { "name": "Mana Potion", "type": "consumable", "subtype": "potion", "grid_size": Vector2(1, 1), "valid_slots": [], "texture": "res://assets/items/mana_potion.png", "base_stats": {"mana_restore": 50}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0} },

	# --- SCROLLS ---
	# (Keep existing scrolls)
	"scroll_of_identify": { "name": "Scroll of Identify", "type": "scroll", "subtype": "scroll", "grid_size": Vector2(1, 2), "valid_slots": [], "texture": "res://assets/items/scroll_identify.png", "base_stats": {}, "level_req": 1, "stat_req": {"strength": 0, "dexterity": 0, "wisdom": 0} },
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

# --- END OF FILE BaseItems.txt ---
