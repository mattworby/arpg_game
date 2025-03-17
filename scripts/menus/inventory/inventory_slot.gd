# InventorySlot.gd - Attach to the InventorySlot scene
extends Panel

var item = null
var slot_type = "default" # For equipment slots: weapon, helmet, armor, etc.

signal item_added(item)
signal item_removed(item)

func _ready():
	# Set up the visual appearance
	custom_minimum_size = Vector2(40, 40)

func has_item():
	return item != null

func set_item(new_item):
	if new_item.get_parent():
		new_item.get_parent().remove_child(new_item)
	
	item = new_item
	add_child(item)
	
	# Center the item in the slot
	item.position = (size - item.size) / 2
	
	emit_signal("item_added", item)

func remove_item():
	if item:
		var old_item = item
		remove_child(item)
		emit_signal("item_removed", old_item)
		return old_item
	return null

func can_accept_item(check_item):
	# For equipment slots, check item type compatibility
	if slot_type != "default":
		return check_item.get_equip_type() == slot_type
	
	# Regular inventory slots can accept any item
	return true
