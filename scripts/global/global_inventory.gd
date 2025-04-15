extends Node

signal inventory_updated

var inventory_scene: PackedScene = preload("res://scenes/menus/inventory/inventory.tscn")
var inventory_instance: Control = null

func _ready():
	if inventory_scene:
		inventory_instance = inventory_scene.instantiate()
		if is_instance_valid(inventory_instance):
			inventory_instance.name = "PlayerInventoryUI"
			inventory_instance.visible = false
			if inventory_instance.has_signal("inventory_changed"):
				inventory_instance.inventory_changed.connect(_on_inventory_changed)
			else:
				printerr("GlobalInventory Warning: Inventory scene has no 'inventory_changed' signal.")
			print("GlobalInventory: Inventory instance created and hidden.")
		else:
			printerr("GlobalInventory Error: Failed to instantiate inventory scene.")
	else:
		printerr("GlobalInventory Error: Inventory scene not preloaded correctly.")

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.is_echo():
		var current_scene = get_tree().current_scene
		if current_scene and current_scene.name != "TitleScreen":
			if event.keycode == KEY_I:
				var focused_node = get_viewport().gui_get_focus_owner()
				if focused_node is LineEdit or focused_node is TextEdit:
					print("Inventory toggle blocked by focused input field.")
				else:
					toggle_inventory()
					get_viewport().set_input_as_handled()

func toggle_inventory():
	if not is_instance_valid(inventory_instance):
		printerr("Cannot toggle inventory: Instance is not valid!")
		return

	var player = get_tree().get_first_node_in_group("player")

	if not inventory_instance.is_inside_tree():
		var camera = get_viewport().get_camera_2d()

		if not is_instance_valid(camera):
			printerr("GlobalInventory Error: Cannot find active Camera2D to attach inventory UI!")
			return 

		print("Adding inventory UI as child of Camera2D: ", camera.name)
		var target_parent = camera 

		target_parent.add_child(inventory_instance)

		inventory_instance.visible = false
		inventory_instance.z_index = 100

		target_parent.move_child(inventory_instance, target_parent.get_child_count() - 1)

		if inventory_instance.has_method("toggle_inventory"):
			inventory_instance.toggle_inventory()

		if player and player.has_method("lock_movement"):
			player.lock_movement()
		print("Inventory Opened (Attached to Camera)")

	else:
		inventory_instance.visible = false
		if inventory_instance.has_method("toggle_inventory"):
			inventory_instance.toggle_inventory()

		var parent = inventory_instance.get_parent()
		if is_instance_valid(parent):
			call_deferred("remove_inventory_child", parent)

		if player and player.has_method("unlock_movement"):
			player.unlock_movement()
		print("Inventory Closed")
		
func remove_inventory_child(parent_node: Node):
	if is_instance_valid(parent_node) and is_instance_valid(inventory_instance) and inventory_instance.get_parent() == parent_node:
		parent_node.remove_child(inventory_instance)

func _on_inventory_changed(data: Dictionary):
	print("GlobalInventory: Relaying inventory_updated signal.")
	emit_signal("inventory_updated")

func get_inventory_save_data() -> Dictionary:
	if is_instance_valid(inventory_instance) and inventory_instance.has_method("get_save_data"):
		return inventory_instance.get_save_data()
	else:
		printerr("GlobalInventory: Cannot get save data, instance invalid or method missing.")
		return {"grid": {}, "equipped": {}}

func load_inventory_state(data: Dictionary):
	if not is_instance_valid(inventory_instance):
		printerr("GlobalInventory: Cannot load state, inventory instance is invalid.")
		return

	if inventory_instance.has_method("load_inventory_state"):
		inventory_instance.load_inventory_state(data)
	else:
		printerr("GlobalInventory: Cannot load state, instance is missing 'load_inventory_state' method.")

func add_item_to_inventory(item_id: String) -> bool:
	if is_instance_valid(inventory_instance) and inventory_instance.has_method("add_item"):
		return inventory_instance.add_item(item_id)
	printerr("GlobalInventory: Cannot add item, instance invalid or method missing.")
	return false

func remove_item_from_inventory(item_id: String) -> bool:
	if is_instance_valid(inventory_instance) and inventory_instance.has_method("remove_item"):
		inventory_instance.remove_item(item_id) 
		return true
	printerr("GlobalInventory: Cannot remove item, instance invalid or method missing.")
	return false

func check_has_item(item_id: String) -> bool:
	if is_instance_valid(inventory_instance) and inventory_instance.has_method("has_item"):
		return inventory_instance.has_item(item_id)
	printerr("GlobalInventory: Cannot check item, instance invalid or method missing.")
	return false
