extends Node

signal inventory_changed(data)
signal equipment_changed(slot_id: int, item_data: Dictionary)

var inventory_scene = preload("res://scenes/menus/inventory/inventory.tscn")
var inventory_instance = null

func _ready():
	inventory_instance = inventory_scene.instantiate()
	inventory_instance.visible = false

func _input(event):
	if event is InputEventKey and event.pressed and not event.is_echo() and !get_tree().get_current_scene().name == "TitleScreen":
		if event.keycode == KEY_I and !get_tree().paused:
			toggle_inventory()

func toggle_inventory():
	if not is_instance_valid(inventory_instance): return
	var player = get_tree().get_first_node_in_group("player")
	if !inventory_instance.visible:
		if player:
			player.lock_movement()
		inventory_instance.toggle_inventory()
	else:
		if player:
			player.unlock_movement()
		inventory_instance.toggle_inventory()
		
func get_inventory_save_data() -> Dictionary:
	if is_instance_valid(inventory_instance) and inventory_instance.has_method("get_save_data"):
		return inventory_instance.get_save_data()
	else:
		if is_instance_valid(inventory_instance):
			printerr("GlobalInventory: Cannot get save data, inventory instance missing get_save_data method.")
		return {}

func load_inventory_state(data: Dictionary):
	if is_instance_valid(inventory_instance) and inventory_instance.has_method("load_inventory_state"):
		print("GlobalInventory: Telling inventory_instance to load state.")
		inventory_instance.load_inventory_state(data)
	elif is_instance_valid(inventory_instance):
		printerr("GlobalInventory: Cannot load state, inventory instance missing load_inventory_state method.")
	else:
		printerr("GlobalInventory: Cannot load state, inventory instance is null.")
		
func initialize_inventory():
			
	var viewport = get_tree().get_root().get_viewport()
	var camera = viewport.get_camera_2d()
	
	if not is_instance_valid(inventory_instance):
		printerr("GlobalInventory Error: inventory_instance is not valid during initialize_inventory!")
		inventory_instance = inventory_scene.instantiate()
		inventory_instance.visible = false

	if not inventory_instance.is_inside_tree():
		print("GlobalInventory: Adding inventory instance to the scene tree.")
		camera.add_child(inventory_instance)
		inventory_instance.z_index = 100
		
		call_deferred("_check_and_load_pending_inventory")
	
	else:
		print("GlobalInventory: Instance already in tree.")
		call_deferred("_check_and_load_pending_inventory")
		
func _check_and_load_pending_inventory():
	print("GlobalInventory: _check_and_load_pending_inventory() Deferred Check Starting.")
	if not PlayerData:
		printerr("GlobalInventory Error: PlayerData not found during deferred check!")
		return
	if not is_instance_valid(inventory_instance):
		printerr("GlobalInventory Error: inventory_instance invalid during deferred check!")
		return

	var pending_data = PlayerData.get_pending_inventory_data()
	if not pending_data.is_empty():
		print("GlobalInventory: Pending data found. Ensuring instance is ready...")
		await inventory_instance.ready
		print("GlobalInventory: Instance ready. Loading state...")
		load_inventory_state(pending_data)
		PlayerData.clear_pending_inventory_data()
	else:
		print("GlobalInventory: No pending inventory data found (deferred check).")

func remove_inventory():
	if is_instance_valid(inventory_instance) and inventory_instance.is_inside_tree():
		inventory_instance.queue_free()
		inventory_instance = null
	
func get_inventory_node():
	return inventory_instance
	
func inventory_updated(data: Dictionary):
	emit_signal("inventory_changed", data)
	PlayerData.save_current_character_data()

func equipment_updated(slot: int, data: Dictionary):
	emit_signal("equipment_changed", slot, data)
	PlayerData.save_current_character_data()
	
