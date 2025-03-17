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
	# Global input handling for inventory toggle
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_I and !get_tree().paused:
			toggle_inventory()

func toggle_inventory():
	# Only add to scene tree when needed
	if !inventory_instance.is_inside_tree():
		get_tree().get_current_scene().add_child(inventory_instance)
	
	inventory_instance.toggle_inventory()

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
