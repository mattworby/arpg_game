# InventoryManager.gd - Add this as an autoload/singleton
extends Node

signal inventory_updated

var inventory_scene = preload("res://scenes/menus/inventory/inventory.tscn")
var inventory_instance = null
var player_inventory = {}

func _ready():
	# Create inventory instance
	inventory_instance = inventory_scene.instantiate()
	inventory_instance.visible = false
	# Don't add to tree yet - will be added on demand

	# Connect signals from inventory
	inventory_instance.inventory_changed.connect(_on_inventory_changed)

func _input(event):
	if event is InputEventKey and event.pressed and not event.is_echo() and !get_tree().get_current_scene().name == "TitleScreen":
		if event.keycode == KEY_I and !get_tree().paused:
			toggle_inventory()

func toggle_inventory():
	var player = get_tree().get_first_node_in_group("player")
	# Only add inventory when needed
	if !inventory_instance.is_inside_tree():
		# Get current camera and add inventory as its child
		var viewport = get_tree().get_root().get_viewport()
		var camera = viewport.get_camera_2d()
		
		if camera:
			camera.add_child(inventory_instance)		
			
			# Ensure inventory is in front with higher z_index
			inventory_instance.z_index = 100
			
			if player:
				player.lock_movement()
			
			inventory_instance.toggle_inventory()
	else:
		var parent = inventory_instance.get_parent()
		if parent:
			parent.remove_child(inventory_instance)
			inventory_instance.toggle_inventory()
			if player:
				player.unlock_movement()

func _on_inventory_changed(data):
	# Store updated inventory data
	player_inventory = data
	emit_signal("inventory_updated")

func add_item(item_id, quantity=1):
	if inventory_instance:
		return inventory_instance.add_item(item_id, quantity)
	return false

func remove_item(item_id, quantity=1):
	if inventory_instance:
		return inventory_instance.remove_item(item_id, quantity)
	return false

func has_item(item_id, quantity=1):
	if inventory_instance:
		return inventory_instance.has_item(item_id, quantity)
	return false

func save_inventory_data():
	return player_inventory

func load_inventory_data(data):
	player_inventory = data
	if inventory_instance:
		inventory_instance.load_inventory(data)
