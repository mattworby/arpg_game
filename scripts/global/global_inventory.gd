extends Node

signal inventory_updated

var inventory_scene: PackedScene = preload("res://scenes/menus/inventory/inventory.tscn")
var inventory_instance: Control = null
var canvas_layer: CanvasLayer = null

func _ready():
	# Create CanvasLayer
	canvas_layer = CanvasLayer.new()
	canvas_layer.name = "InventoryCanvasLayer"
	canvas_layer.layer = 10
	add_child(canvas_layer)

	if inventory_scene:
		inventory_instance = inventory_scene.instantiate()
		if is_instance_valid(inventory_instance):
			inventory_instance.name = "PlayerInventoryUI"
			canvas_layer.add_child(inventory_instance) 
			inventory_instance.visible = false
			inventory_instance.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

			if inventory_instance.has_signal("inventory_changed"):
				inventory_instance.inventory_changed.connect(_on_inventory_changed)
			else:
				printerr("GlobalInventory Warning: Inventory scene node lacks 'inventory_changed' signal.")

			print("GlobalInventory: Inventory instance created, added to CanvasLayer, layout set, hidden.")
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
					print("GlobalInventory: Inventory toggle blocked by focused input field.")
				else:
					toggle_inventory()
					get_viewport().set_input_as_handled()

func toggle_inventory():
	if not is_instance_valid(inventory_instance):
		printerr("Cannot toggle inventory: Instance is not valid!")
		return

	inventory_instance.visible = not inventory_instance.visible
	print("GlobalInventory: Inventory toggled. Visible: ", inventory_instance.visible)

	var player_nodes = get_tree().get_nodes_in_group("player")
	if not player_nodes.is_empty():
		var player = player_nodes[0]
		if inventory_instance.visible:
			if player.has_method("lock_movement"): player.lock_movement()
		else:
			if player.has_method("unlock_movement"): player.unlock_movement()

func _on_inventory_changed(data: Dictionary):
	emit_signal("inventory_updated")

func get_inventory_node() -> Control:
	return inventory_instance

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

func add_item_to_inventory(item_data: Dictionary) -> bool: 
	if is_instance_valid(inventory_instance) and inventory_instance.has_method("add_generated_item"):
		return inventory_instance.add_generated_item(item_data)
	printerr("GlobalInventory: Cannot add item, instance invalid or method 'add_generated_item' missing.")
	return false

func remove_item_from_inventory(instance_id: String) -> bool: 
	if is_instance_valid(inventory_instance) and inventory_instance.has_method("remove_item"):
		return inventory_instance.remove_item(instance_id)
	printerr("GlobalInventory: Cannot remove item, instance invalid or method missing.")
	return false

func check_has_item(instance_id: String) -> bool:
	if is_instance_valid(inventory_instance) and inventory_instance.has_method("has_item"):
		return inventory_instance.has_item(instance_id) 
	printerr("GlobalInventory: Cannot check item, instance invalid or method missing.")
	return false
