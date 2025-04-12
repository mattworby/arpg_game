extends Node

signal inventory_updated(grid_data, equipment_data)

var inventory_scene = preload("res://scenes/menus/inventory/inventory.tscn")
var inventory_instance = null

var player_grid_items: Array = [
	{"item_id": "healing_potion_small", "grid_position": Vector2i(0, 0)},
	{"item_id": "iron_sword", "grid_position": Vector2i(1, 0)},
	{"item_id": "wooden_shield", "grid_position": Vector2i(5, 3)},
	{"item_id": "gold_ring", "grid_position": Vector2i(0, 5)},
]
var player_equipment: Dictionary = {
	"helmet": "leather_helmet",
}

func _ready():
	pass

func _input(event):
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.name != "TitleScreen" and current_scene.name != "MainMenu": # Example scene names
		if event is InputEventKey and event.keycode == KEY_I and event.pressed and not event.is_echo():
			toggle_inventory()


func get_inventory_node():
	if is_instance_valid(inventory_instance):
		return inventory_instance

	var camera = get_tree().get_root().get_viewport().get_camera_2d()
	if camera:
		var existing_instance = camera.get_node_or_null("Inventory")
		if is_instance_valid(existing_instance):
			inventory_instance = existing_instance
			if not inventory_instance.is_connected("inventory_state_changed", Callable(self, "_on_inventory_state_changed")):
				inventory_instance.inventory_state_changed.connect(_on_inventory_state_changed)
			return inventory_instance
	return null


func toggle_inventory():
	var player = get_tree().get_first_node_in_group("player")
	var existing_inventory = get_inventory_node()

	if is_instance_valid(existing_inventory) and existing_inventory.visible:
		print("GlobalInventory: Closing Inventory.")
		existing_inventory.toggle_inventory()

		call_deferred("_remove_inventory_from_tree")

		if player and player.has_method("unlock_movement"):
			player.unlock_movement()
		get_tree().paused = false

	else:
		print("GlobalInventory: Opening Inventory.")
		if not is_instance_valid(inventory_instance):
			inventory_instance = inventory_scene.instantiate()
			inventory_instance.name = "Inventory"
			inventory_instance.inventory_state_changed.connect(_on_inventory_state_changed)

		var camera = get_tree().get_root().get_viewport().get_camera_2d()
		if camera:
			camera.add_child(inventory_instance)
			inventory_instance.z_index = 100
			inventory_instance.load_inventory_data(player_grid_items, player_equipment)
			inventory_instance.toggle_inventory()

			if player and player.has_method("lock_movement"):
				player.lock_movement()
		else:
			printerr("GlobalInventory: Cannot open inventory - No 2D Camera found in viewport.")


func _remove_inventory_from_tree():
	var node_to_remove = get_inventory_node()
	if is_instance_valid(node_to_remove) and node_to_remove.is_inside_tree():
		node_to_remove.get_parent().remove_child(node_to_remove)
		print("GlobalInventory: Removed inventory instance from tree.")


func _on_inventory_state_changed(grid_data: Array, equipment_data: Dictionary):
	player_grid_items = grid_data
	player_equipment = equipment_data
	emit_signal("inventory_updated", grid_data, equipment_data)
	print("GlobalInventory: Received updated state.")

func get_save_data() -> Dictionary:
	return {
		"grid_items": player_grid_items,
		"equipment": player_equipment
	}

func load_save_data(data: Dictionary):
	if data.has("grid_items"):
		player_grid_items = data["grid_items"]
	if data.has("equipment"):
		player_equipment = data["equipment"]

	var current_inventory = get_inventory_node()
	if is_instance_valid(current_inventory) and current_inventory.is_inside_tree():
		current_inventory.load_inventory_data(player_grid_items, player_equipment)
