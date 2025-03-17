# Inventory.gd (Attach to the root node of the inventory scene)
extends Control

const MAX_SLOTS = 60  # Standard ARPG inventory size (10x6)
const SLOT_SIZE = Vector2(40, 40)
const GRID_COLS = 10

var inventory_data = {}  # Will store item references by position
var dragging_item = null
var drag_offset = Vector2.ZERO
var original_slot = null

signal inventory_changed(data)

func _ready():
	# Hide inventory on start
	visible = false
	# Connect signals
	get_viewport().size_changed.connect(_on_window_resize)
	_setup_inventory_grid()
	_setup_equipment_slots()
	
	# Testing - add some sample items
	_add_test_items()

func _input(event):
	# Handle inventory toggle
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_I:
			toggle_inventory()
	
	# Handle drag and drop
	if visible:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					_start_drag(event.position)
				else:
					_end_drag(event.position)
		
		elif event is InputEventMouseMotion and dragging_item != null:
			dragging_item.position = event.position - drag_offset

func toggle_inventory():
	visible = !visible
	# Pause game when inventory open (except animations)
	get_tree().paused = visible
	
	if visible:
		# Ensure proper focus for keyboard navigation
		grab_focus()

func _setup_inventory_grid():
	var grid = $CenterContainer/InventoryContainer/InventoryPanel/MarginContainer/VBoxContainer/GridContainer
	grid.columns = GRID_COLS
	
	# Create inventory slots
	for i in range(MAX_SLOTS):
		var slot = preload("res://scenes/menus/inventory/inventory.tscn").instantiate()
		slot.name = "Slot" + str(i)
		slot.gui_input.connect(_on_slot_gui_input.bind(slot))
		grid.add_child(slot)

func _setup_equipment_slots():
	# Connect equipment slot signals
	for slot in $CenterContainer/InventoryContainer/CharacterPanel/MarginContainer/VBoxContainer/EquipmentSlots.get_children():
		slot.gui_input.connect(_on_equipment_slot_gui_input.bind(slot))

func _start_drag(mouse_pos):
	# Find which slot was clicked
	var slot = _get_slot_under_mouse(mouse_pos)
	if slot and slot.has_item():
		dragging_item = slot.item
		original_slot = slot
		drag_offset = mouse_pos - dragging_item.position
		dragging_item.z_index = 1  # Bring to front while dragging
		# Remove from original slot (visually only)
		slot.remove_item()
		# Add to canvas layer for dragging
		add_child(dragging_item)

func _end_drag(mouse_pos):
	if dragging_item:
		var target_slot = _get_slot_under_mouse(mouse_pos)
		
		if target_slot and target_slot.can_accept_item(dragging_item):
			# Place in new slot
			if target_slot.has_item():
				# Swap items if slot already contains an item
				var temp_item = target_slot.item
				target_slot.remove_item()
				original_slot.set_item(temp_item)
				target_slot.set_item(dragging_item)
			else:
				target_slot.set_item(dragging_item)
				
			# Update inventory data
			_update_inventory_data()
		else:
			# Return to original position
			original_slot.set_item(dragging_item)
		
		# Reset dragging state
		dragging_item.z_index = 0
		dragging_item = null
		original_slot = null

func _get_slot_under_mouse(mouse_pos):
	# Check inventory slots
	for slot in $CenterContainer/InventoryContainer/InventoryPanel/MarginContainer/VBoxContainer/GridContainer.get_children():
		if slot.get_global_rect().has_point(mouse_pos):
			return slot
	
	# Check equipment slots
	for slot in $CenterContainer/InventoryContainer/CharacterPanel/MarginContainer/VBoxContainer/EquipmentSlots.get_children():
		if slot.get_global_rect().has_point(mouse_pos):
			return slot
	
	return null

func _on_slot_gui_input(event, slot):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_handle_right_click(slot)

func _on_equipment_slot_gui_input(event, slot):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_handle_right_click(slot)

func _handle_right_click(slot):
	if slot.has_item():
		var item = slot.item
		
		# For equipment slots: unequip
		if slot.get_parent().name == "EquipmentSlots":
			# Find free inventory slot
			var free_slot = _find_free_inventory_slot()
			if free_slot:
				var temp_item = slot.item
				slot.remove_item()
				free_slot.set_item(temp_item)
				_update_inventory_data()
		
		# For inventory slots: equip if possible
		else:
			var equip_type = item.get_equip_type()
			if equip_type != "":
				var equip_slot = _find_equipment_slot_by_type(equip_type)
				if equip_slot:
					var temp_item = slot.item
					slot.remove_item()
					
					# Swap with currently equipped item if any
					if equip_slot.has_item():
						var old_item = equip_slot.item
						equip_slot.remove_item()
						slot.set_item(old_item)
					
					equip_slot.set_item(temp_item)
					_update_inventory_data()

func _find_free_inventory_slot():
	for slot in $CenterContainer/InventoryContainer/InventoryPanel/MarginContainer/VBoxContainer/GridContainer.get_children():
		if not slot.has_item():
			return slot
	return null

func _find_equipment_slot_by_type(type):
	for slot in $CenterContainer/InventoryContainer/CharacterPanel/MarginContainer/VBoxContainer/EquipmentSlots.get_children():
		if slot.slot_type == type and not slot.has_item():
			return slot
	return null

func _update_inventory_data():
	# Update the inventory data dictionary based on current state
	inventory_data.clear()
	
	# Inventory slots
	for i in range(MAX_SLOTS):
		var slot = $CenterContainer/InventoryContainer/InventoryPanel/MarginContainer/VBoxContainer/GridContainer.get_child(i)
		if slot.has_item():
			inventory_data["inventory_" + str(i)] = {
				"item_id": slot.item.item_id,
				"quantity": slot.item.quantity
			}
	
	# Equipment slots
	for slot in $CenterContainer/InventoryContainer/CharacterPanel/MarginContainer/VBoxContainer/EquipmentSlots.get_children():
		if slot.has_item():
			inventory_data["equip_" + slot.slot_type] = {
				"item_id": slot.item.item_id,
				"quantity": 1
			}
	
	# Emit signal for inventory manager
	emit_signal("inventory_changed", inventory_data)

func _on_window_resize():
	# Center the inventory on screen resize
	position = (get_viewport_rect().size - size) / 2

func _add_test_items():
	# For testing - add some example items
	var test_items = [
		{"id": "sword1", "name": "Iron Sword", "type": "weapon", "icon": "res://assets/icons/sword.png"},
		{"id": "helmet1", "name": "Leather Cap", "type": "helmet", "icon": "res://assets/icons/helmet.png"},
		{"id": "potion1", "name": "Health Potion", "type": "consumable", "icon": "res://assets/icons/potion_red.png"},
	]
	
	for i in range(min(test_items.size(), 3)):
		var item_data = test_items[i]
		var new_item = preload("res://scenes/menus/inventory/inventory_item.tscn").instantiate()
		new_item.initialize(item_data.id, item_data.name, item_data.type, item_data.icon)
		$CenterContainer/InventoryContainer/InventoryPanel/MarginContainer/VBoxContainer/GridContainer.get_child(i).set_item(new_item)

# Added methods for the global inventory manager
func add_item(item_id, quantity=1):
	# Find related item data (should come from your item database)
	var item_data = _get_item_data_by_id(item_id)
	if not item_data:
		return false
		
	# Find free slot
	var free_slot = _find_free_inventory_slot()
	if not free_slot:
		return false
	
	# Create and add item
	var new_item = preload("res://scenes/menus/inventory/inventory_item.tscn").instantiate()
	new_item.initialize(item_data.id, item_data.name, item_data.type, item_data.icon, quantity)
	free_slot.set_item(new_item)
	
	_update_inventory_data()
	return true

func remove_item(item_id, quantity=1):
	# Find slot with this item
	for slot in $CenterContainer/InventoryContainer/InventoryPanel/MarginContainer/VBoxContainer/GridContainer.get_children():
		if slot.has_item() and slot.item.item_id == item_id:
			if slot.item.quantity <= quantity:
				# Remove entire stack
				slot.remove_item()
			else:
				# Reduce quantity
				slot.item.quantity -= quantity
				slot.item.update_tooltip()
				
			_update_inventory_data()
			return true
	
	return false

func has_item(item_id, quantity=1):
	var found_quantity = 0
	
	# Check inventory slots
	for slot in $CenterContainer/InventoryContainer/InventoryPanel/MarginContainer/VBoxContainer/GridContainer.get_children():
		if slot.has_item() and slot.item.item_id == item_id:
			found_quantity += slot.item.quantity
	
	return found_quantity >= quantity

func load_inventory(data):
	inventory_data = data
	_refresh_inventory_display()

func _refresh_inventory_display():
	# Clear all slots
	for slot in $CenterContainer/InventoryContainer/InventoryPanel/MarginContainer/VBoxContainer/GridContainer.get_children():
		if slot.has_item():
			slot.remove_item()
	
	for slot in $CenterContainer/InventoryContainer/CharacterPanel/MarginContainer/VBoxContainer/EquipmentSlots.get_children():
		if slot.has_item():
			slot.remove_item()
	
	# Repopulate from data
	for key in inventory_data:
		var item_data = _get_item_data_by_id(inventory_data[key].item_id)
		if not item_data:
			continue
			
		var new_item = preload("res://scenes/menus/inventory/inventory_item.tscn").instantiate()
		new_item.initialize(
			item_data.id, 
			item_data.name, 
			item_data.type, 
			item_data.icon, 
			inventory_data[key].quantity
		)
		
		if key.begins_with("inventory_"):
			var slot_idx = int(key.split("_")[1])
			if slot_idx < MAX_SLOTS:
				$CenterContainer/InventoryContainer/InventoryPanel/MarginContainer/VBoxContainer/GridContainer.get_child(slot_idx).set_item(new_item)
		
		elif key.begins_with("equip_"):
			var slot_type = key.split("_")[1]
			var equip_slot = _find_equipment_slot_by_type(slot_type)
			if equip_slot:
				equip_slot.set_item(new_item)

func _get_item_data_by_id(item_id):
	# This should connect to your game's item database
	# Placeholder implementation with test items
	var test_items = {
		"sword1": {"id": "sword1", "name": "Iron Sword", "type": "weapon", "icon": "res://assets/icons/sword.png"},
		"helmet1": {"id": "helmet1", "name": "Leather Cap", "type": "helmet", "icon": "res://assets/icons/helmet.png"},
		"potion1": {"id": "potion1", "name": "Health Potion", "type": "consumable", "icon": "res://assets/icons/potion_red.png"},
	}
	
	if test_items.has(item_id):
		return test_items[item_id]
	
	return null
