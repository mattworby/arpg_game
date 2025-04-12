extends Node

# This will be our simple item database for managing item data
# Later you can replace this with a more robust system (JSON files, etc.)

var items = {
	"wooden_shield": {
		"name": "Wooden Shield",
		"type": "shield",
		"grid_size": Vector2(2, 2),
		"valid_slots": [1, 3], # EquipSlot.SHIELD
		"texture": "res://assets/items/wooden_shield.png",
		"stats": {"defense": 5}
	},
	"chainmail": {
		"name": "Chainmail",
		"type": "armor",
		"grid_size": Vector2(2, 3),
		"valid_slots": [1], # EquipSlot.ARMOR
		"texture": "res://assets/items/chainmail.png",
		"stats": {"defense": 10}
	},
	"horned_helmet": {
		"name": "Horned Helmet",
		"type": "helmet",
		"grid_size": Vector2(2, 2),
		"valid_slots": [0], # EquipSlot.HELMET
		"texture": "res://assets/items/horned_helmet.png",
		"stats": {"defense": 3}
	},
	"leather_gloves": {
		"name": "Leather Gloves",
		"type": "gloves",
		"grid_size": Vector2(2, 2),
		"valid_slots": [4], # EquipSlot.GLOVES
		"texture": "res://assets/items/leather_gloves.png",
		"stats": {"defense": 2}
	},
	"leather_boots": {
		"name": "Leather Boots",
		"type": "boots",
		"grid_size": Vector2(2, 2),
		"valid_slots": [6], # EquipSlot.BOOTS
		"texture": "res://assets/items/leather_boots.png",
		"stats": {"defense": 2, "movement_speed": 1}
	},
	"gold_ring": {
		"name": "Gold Ring",
		"type": "ring",
		"grid_size": Vector2(1, 1),
		"valid_slots": [8, 9], # EquipSlot.RING_LEFT, EquipSlot.RING_RIGHT
		"texture": "res://assets/items/gold_ring.png",
		"stats": {"magic_find": 5}
	},
	"silver_amulet": {
		"name": "Silver Amulet",
		"type": "amulet",
		"grid_size": Vector2(1, 1),
		"valid_slots": [7], # EquipSlot.AMULET
		"texture": "res://assets/items/silver_amulet.png",
		"stats": {"magic_resist": 10}
	},
	"leather_belt": {
		"name": "Leather Belt",
		"type": "belt",
		"grid_size": Vector2(2, 1),
		"valid_slots": [5], # EquipSlot.BELT
		"texture": "res://assets/items/leather_belt.png",
		"stats": {"extra_potions": 2}
	},
	"short_sword": {
		"name": "Short Sword",
		"type": "weapon",
		"grid_size": Vector2(1, 3),
		"valid_slots": [2], # EquipSlot.WEAPON
		"texture": "res://assets/items/short_sword.png",
		"stats": {"damage": 5, "attack_speed": 1.2}
	},
	"health_potion": {
		"name": "Health Potion",
		"type": "consumable",
		"grid_size": Vector2(1, 1),
		"valid_slots": [],
		"texture": "res://assets/items/health_potion.png",
		"stats": {"health_restore": 50}
	},
	"mana_potion": {
		"name": "Mana Potion",
		"type": "consumable",
		"grid_size": Vector2(1, 1),
		"valid_slots": [],
		"texture": "res://assets/items/mana_potion.png",
		"stats": {"mana_restore": 50}
	},
	"scroll_of_identify": {
		"name": "Scroll of Identify",
		"type": "scroll",
		"grid_size": Vector2(1, 2),
		"valid_slots": [],
		"texture": "res://assets/items/scroll_identify.png",
		"stats": {}
	},
	"large_axe": {
		"name": "Large Axe",
		"type": "weapon",
		"grid_size": Vector2(2, 3),
		"valid_slots": [2], # EquipSlot.WEAPON
		"texture": "res://assets/items/large_axe.png",
		"stats": {"damage": 12, "attack_speed": 0.8}
	}
}

func get_item(item_id):
	if items.has(item_id):
		return items[item_id]
	return null

func get_random_item():
	var keys = items.keys()
	var random_index = randi() % keys.size()
	return items[keys[random_index]]
