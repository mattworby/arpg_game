extends Node

var items = {
	"healing_potion_small": {
		"name": "Small Healing Potion",
		"texture_path": "res://assets/items/potions/small_red_potion.jpg",
		"size": Vector2i(1, 1), 
		"equip_type": "consumable",
		"stackable": true,
		"max_stack_size": 10,
		"description": "Restores a small amount of health."
	},
	"iron_sword": {
		"name": "Iron Sword",
		"texture_path": "res://assets/items/weapons/sword.png",
		"size": Vector2i(1, 3),
		"equip_type": "weapon",
		"stackable": false,
		"description": "A basic iron sword."
	},
	"wooden_shield": {
		"name": "Wooden Shield",
		"texture_path": "res://assets/items/shields/shield.png",
		"size": Vector2i(2, 2),
		"equip_type": "shield",
		"stackable": false,
		"description": "A simple wooden shield."
	},
	"leather_helmet": {
		"name": "Leather Helmet",
		"texture_path": "res://assets/items/armour/helmet.png",
		"size": Vector2i(2, 2),
		"equip_type": "helmet",
		"stackable": false,
		"description": "Basic head protection."
	},
	"gold_ring": {
		"name": "Gold Ring",
		"texture_path": "res://assets/items/jewelry/ring_gold.png",
		"size": Vector2i(1, 1),
		"equip_type": "ring",
		"stackable": false,
		"description": "A plain gold ring."
	}
	# Add more items here...
}

func get_item_data(item_id: String) -> Dictionary:
	if items.has(item_id):
		return items[item_id].duplicate()
	else:
		printerr("ItemDatabase: Item ID not found: ", item_id)
		return {}

func get_item_size(item_id: String) -> Vector2i:
	if items.has(item_id):
		return items[item_id].get("size", Vector2i(1, 1))
	return Vector2i(1, 1)

func get_item_texture_path(item_id: String) -> String:
	if items.has(item_id):
		return items[item_id].get("texture_path", "")
	return ""

func get_item_equip_type(item_id: String) -> String:
	if items.has(item_id):
		return items[item_id].get("equip_type", "none")
	return "none"

func create_instance_of_item(item_id: String) -> Dictionary:
	var base_data = get_item_data(item_id)
	if base_data.is_empty():
		return {}

	var instance_data = base_data.duplicate()
	# Add a unique instance ID if needed for tracking specific items
	# instance_data["instance_id"] = str(Time.get_unix_time_from_system()) + "_" + item_id
	return instance_data
