extends Control

signal inventory_changed(data)

const INVENTORY_WIDTH_PERCENT = 0.35
const GRID_SIZE = Vector2(10, 4)  # Width x Height of inventory grid
const CELL_SIZE = 32  # Size of each inventory cell in pixels

# Equipment slot identifiers
enum EquipSlot {
	HELMET,
	ARMOR,
	WEAPON,
	SHIELD,
	GLOVES,
	BELT,
	BOOTS,
	AMULET,
	RING_LEFT,
	RING_RIGHT
}

# Dictionary mapping slot enums to node paths
var slot_paths = {
	EquipSlot.HELMET: "InventoryWindow/EquipmentPanel/MiddleSlots/HelmetSlot",
	EquipSlot.ARMOR: "InventoryWindow/EquipmentPanel/MiddleSlots/ArmorSlot",
	EquipSlot.WEAPON: "InventoryWindow/EquipmentPanel/LeftSlots/WeaponSlot",
	EquipSlot.SHIELD: "InventoryWindow/EquipmentPanel/RightSlots/ShieldSlot",
	EquipSlot.GLOVES: "InventoryWindow/EquipmentPanel/LeftSlots/GlovesSlot",
	EquipSlot.BELT: "InventoryWindow/EquipmentPanel/MiddleBottomSlots/BeltSlot",
	EquipSlot.BOOTS: "InventoryWindow/EquipmentPanel/RightSlots/BootsSlot",
	EquipSlot.AMULET: "InventoryWindow/EquipmentPanel/RightSlots/AmuletSlot",
	EquipSlot.RING_LEFT: "InventoryWindow/EquipmentPanel/MiddleBottomSlots/LeftRingSlot",
	EquipSlot.RING_RIGHT: "InventoryWindow/EquipmentPanel/MiddleBottomSlots/RightRingSlot"
}

# Store item data with position and size
var inventory_data = {}  # Format: {item_id: {item_data, grid_position, grid_size}}
var equipped_items = {}  # Format: {slot_id: item_id}

# For drag and drop functionality
var dragging_item = null
var drag_start_position = Vector2()
var drag_start_grid_pos = Vector2()
var original_parent = null

# Tooltip
var tooltip_instance = null
var tooltip_scene = preload("res://scenes/menus/inventory/item_tooltip.tscn")

func _ready():
	# Initialize inventory grid
	var inventory_grid = $InventoryWindow/InventoryPanel/InventoryGrid
	inventory_grid.custom_minimum_size = Vector2(GRID_SIZE.x * CELL_SIZE, GRID_SIZE.y * CELL_SIZE)
	
	# Initialize equipment slots
	for slot_id in slot_paths:
		var slot = get_node(slot_paths[slot_id])
		if slot:
			# Don't try to set slot_id
			slot.connect("gui_input", _on_equipment_slot_input.bind(slot, slot_id))
	
	# Create tooltip instance but don't add to scene yet
	tooltip_instance = tooltip_scene.instantiate()
	tooltip_instance.visible = false
	
	# Add some test items
	_add_test_items()

func _add_test_items():
	# Add placeholder items for demonstration
	var test_items = {
		"wooden_shield": {
			"name": "Wooden Shield",
			"type": "shield",
			"grid_size": Vector2(2, 2),
			"valid_slots": [EquipSlot.SHIELD],
			"texture": "res://assets/items/wooden_shield.png",
			"stats": {"defense": 5}
		},
		"chainmail": {
			"name": "Chainmail",
			"type": "armor",
			"grid_size": Vector2(2, 3),
			"valid_slots": [EquipSlot.ARMOR],
			"texture": "res://assets/items/chainmail.png",
			"stats": {"defense": 10}
		},
		"horned_helmet": {
			"name": "Horned Helmet",
			"type": "helmet",
			"grid_size": Vector2(2, 2),
			"valid_slots": [EquipSlot.HELMET],
			"texture": "res://assets/items/horned_helmet.png",
			"stats": {"defense": 3}
		},
		"leather_gloves": {
			"name": "Leather Gloves",
			"type": "gloves",
			"grid_size": Vector2(2, 2),
			"valid_slots": [EquipSlot.GLOVES],
			"texture": "res://assets/items/leather_gloves.png",
			"stats": {"defense": 2}
		},
		"gold_ring": {
			"name": "Gold Ring",
			"type": "ring",
			"grid_size": Vector2(1, 1),
			"valid_slots": [EquipSlot.RING_LEFT, EquipSlot.RING_RIGHT],
			"texture": "res://assets/items/gold_ring.png",
			"stats": {"magic_find": 5}
		}
	}
	
	# Place items in inventory
	add_item_at("wooden_shield", test_items["wooden_shield"], Vector2(0, 0))
	add_item_at("chainmail", test_items["chainmail"], Vector2(3, 0))
	add_item_at("horned_helmet", test_items["horned_helmet"], Vector2(6, 0))
	add_item_at("leather_gloves", test_items["leather_gloves"], Vector2(0, 2))
	add_item_at("gold_ring", test_items["gold_ring"], Vector2(8, 0))

func toggle_inventory():
	visible = !visible
	get_tree().paused = visible
	
	if visible and !tooltip_instance.is_inside_tree():
		add_child(tooltip_instance)

func _process(_delta):
	# Update tooltip position if visible
	if tooltip_instance and tooltip_instance.visible:
		tooltip_instance.global_position = get_global_mouse_position() + Vector2(15, 15)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Update dragging item position
		if dragging_item:
			dragging_item.global_position = get_global_mouse_position() - dragging_item.size / 2

func add_item(item_id, quantity=1):
	# Find first available slot in inventory grid
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var grid_pos = Vector2(x, y)
			if can_place_item_at(item_id, grid_pos):
				return add_item_at(item_id, inventory_data[item_id], grid_pos)
	return false

func add_item_at(item_id, item_data, grid_position):
	# Create item instance if it doesn't exist
	if !inventory_data.has(item_id):
		inventory_data[item_id] = item_data
		inventory_data[item_id]["grid_position"] = grid_position
		
		# Create visual representation
		var item_instance = create_item_instance(item_id, item_data)
		
		# Position in grid
		var grid_pixel_pos = grid_to_pixel(grid_position)
		item_instance.position = grid_pixel_pos
		
		# Add to grid
		$InventoryWindow/InventoryPanel/InventoryGrid.add_child(item_instance)
		
		# Update inventory data
		emit_signal("inventory_changed", inventory_data)
		return true
	
	return false

func create_item_instance(item_id, item_data):
	var item_instance = TextureRect.new()
	item_instance.name = item_id
	item_instance.expand = true
	item_instance.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	item_instance.custom_minimum_size = Vector2(item_data.grid_size.x * CELL_SIZE, item_data.grid_size.y * CELL_SIZE)
	item_instance.size = item_instance.custom_minimum_size
	
	# Set texture
	var texture_path = item_data.texture
	if ResourceLoader.exists(texture_path):
		item_instance.texture = load(texture_path)
	else:
		# Use placeholder if texture doesn't exist
		var placeholder = ColorRect.new()
		placeholder.color = Color(randf(), randf(), randf(), 0.8)
		placeholder.custom_minimum_size = item_instance.custom_minimum_size
		item_instance.add_child(placeholder)
		
		var label = Label.new()
		label.text = item_data.name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size = item_instance.custom_minimum_size
		placeholder.add_child(label)
	
	# Make draggable
	item_instance.mouse_filter = Control.MOUSE_FILTER_STOP
	item_instance.connect("gui_input", _on_item_gui_input.bind(item_instance, item_id))
	
	return item_instance

func can_place_item_at(item_id, grid_position):
	var item_data = inventory_data.get(item_id)
	if !item_data:
		return false
		
	var item_size = item_data.grid_size
	
	# Check if item fits within grid boundaries
	if grid_position.x < 0 or grid_position.y < 0:
		return false
	if grid_position.x + item_size.x > GRID_SIZE.x:
		return false
	if grid_position.y + item_size.y > GRID_SIZE.y:
		return false
	
	# Check if area is free of other items
	for x in range(item_size.x):
		for y in range(item_size.y):
			var check_pos = grid_position + Vector2(x, y)
			for other_id in inventory_data:
				if other_id == item_id:
					continue  # Skip self
				
				var other_data = inventory_data[other_id]
				var other_pos = other_data.grid_position
				var other_size = other_data.grid_size
				
				if check_pos.x >= other_pos.x and check_pos.x < other_pos.x + other_size.x and \
				   check_pos.y >= other_pos.y and check_pos.y < other_pos.y + other_size.y:
					return false
	
	return true

func remove_item(item_id):
	if inventory_data.has(item_id):
		# Remove visual representation
		var item_node = $InventoryPanel/InventoryGrid.get_node_or_null(item_id)
		if item_node:
			item_node.queue_free()
		
		# Remove from data
		inventory_data.erase(item_id)
		
		# Check if it was equipped
		for slot in equipped_items.keys():
			if equipped_items[slot] == item_id:
				equipped_items.erase(slot)
				_update_equipment_slot_visual(slot)
		
		emit_signal("inventory_changed", inventory_data)
		return true
	return false

func has_item(item_id, quantity=1):
	return inventory_data.has(item_id)

func grid_to_pixel(grid_pos):
	return Vector2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE)

func pixel_to_grid(pixel_pos):
	return Vector2(int(pixel_pos.x / CELL_SIZE), int(pixel_pos.y / CELL_SIZE))

func _on_item_gui_input(event, item_instance, item_id):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				dragging_item = item_instance
				drag_start_position = item_instance.global_position
				drag_start_grid_pos = inventory_data[item_id].grid_position
				original_parent = item_instance.get_parent()
				
				# Reparent to get it on top of everything
				original_parent.remove_child(item_instance)
				add_child(item_instance)
				
				# Show item tooltip
				_show_tooltip(item_id)
			else:
				# End dragging
				if dragging_item and dragging_item == item_instance:
					_handle_item_drop(item_instance, item_id)
					dragging_item = null
					
					# Hide tooltip
					if tooltip_instance:
						tooltip_instance.visible = false
	
	# Right-click to equip if possible
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_try_equip_item(item_id)

func _handle_item_drop(item_instance, item_id):
	var item_data = inventory_data[item_id]
	var drop_pos = get_global_mouse_position()
	
	# Check if dropped on equipment slot
	for slot_id in slot_paths:
		var slot = get_node(slot_paths[slot_id])
		if slot and slot.get_global_rect().has_point(drop_pos):
			# Try to equip item to this slot
			if _can_equip_to_slot(item_id, slot_id):
				_equip_item(item_id, slot_id)
				return
	
	# Dropped in inventory grid
	if $InventoryPanel/InventoryGrid.get_global_rect().has_point(drop_pos):
		var local_pos = $InventoryPanel/InventoryGrid.get_local_mouse_position()
		var grid_pos = pixel_to_grid(local_pos)
		
		# If it can be placed at new position
		if grid_pos != drag_start_grid_pos and can_place_item_at(item_id, grid_pos):
			# Update position
			inventory_data[item_id].grid_position = grid_pos
			
			# Reparent back to grid
			if item_instance.get_parent() != $InventoryPanel/InventoryGrid:
				remove_child(item_instance)
				$InventoryPanel/InventoryGrid.add_child(item_instance)
			
			item_instance.position = grid_to_pixel(grid_pos)
			emit_signal("inventory_changed", inventory_data)
		else:
			# Return to original position
			if item_instance.get_parent() != original_parent:
				remove_child(item_instance)
				original_parent.add_child(item_instance)
			
			item_instance.position = grid_to_pixel(drag_start_grid_pos)
	else:
		# Dropped outside valid areas - return to original position
		if item_instance.get_parent() != original_parent:
			remove_child(item_instance)
			original_parent.add_child(item_instance)
		
		item_instance.position = grid_to_pixel(drag_start_grid_pos)

func _on_equipment_slot_input(event, slot, slot_id):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		# If there's an item equipped in this slot
		if equipped_items.has(slot_id):
			var item_id = equipped_items[slot_id]
			# Unequip and move back to inventory
			_unequip_item(slot_id)

func _try_equip_item(item_id):
	var item_data = inventory_data[item_id]
	
	# Find first valid slot for this item
	for slot_id in item_data.valid_slots:
		if _can_equip_to_slot(item_id, slot_id):
			_equip_item(item_id, slot_id)
			return true
	
	return false

func _can_equip_to_slot(item_id, slot_id):
	var item_data = inventory_data[item_id]
	
	# Check if slot is valid for this item type
	if item_data.valid_slots.has(slot_id):
		# Check if slot is empty
		if !equipped_items.has(slot_id):
			return true
	
	return false

func _equip_item(item_id, slot_id):
	var item_data = inventory_data[item_id]
	var item_instance = $InventoryPanel/InventoryGrid.get_node_or_null(item_id)
	
	if !item_instance:
		return false
	
	# If another item is already equipped in this slot, unequip it first
	if equipped_items.has(slot_id):
		_unequip_item(slot_id)
	
	# Remove from inventory grid
	$InventoryPanel/InventoryGrid.remove_child(item_instance)
	
	# Add to equipment slot
	var slot_node = get_node(slot_paths[slot_id])
	if slot_node:
		slot_node.add_child(item_instance)
		item_instance.position = Vector2.ZERO
		item_instance.size = slot_node.size
		
		# Update data
		equipped_items[slot_id] = item_id
		emit_signal("inventory_changed", inventory_data)
		return true
	
	# Failed to equip, put back in inventory
	$InventoryPanel/InventoryGrid.add_child(item_instance)
	item_instance.position = grid_to_pixel(item_data.grid_position)
	return false

func _unequip_item(slot_id):
	if !equipped_items.has(slot_id):
		return false
	
	var item_id = equipped_items[slot_id]
	var item_data = inventory_data[item_id]
	var slot_node = get_node(slot_paths[slot_id])
	var item_instance = slot_node.get_node_or_null(item_id)
	
	if !item_instance:
		return false
	
	# Find space in inventory
	var found_space = false
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var grid_pos = Vector2(x, y)
			if can_place_item_at(item_id, grid_pos):
				# Update grid position
				item_data.grid_position = grid_pos
				found_space = true
				break
		if found_space:
			break
	
	if !found_space:
		# No space in inventory
		return false
	
	# Remove from equipment slot
	slot_node.remove_child(item_instance)
	
	# Add back to inventory grid
	$InventoryPanel/InventoryGrid.add_child(item_instance)
	item_instance.custom_minimum_size = Vector2(item_data.grid_size.x * CELL_SIZE, item_data.grid_size.y * CELL_SIZE)
	item_instance.size = item_instance.custom_minimum_size
	item_instance.position = grid_to_pixel(item_data.grid_position)
	
	# Update data
	equipped_items.erase(slot_id)
	emit_signal("inventory_changed", inventory_data)
	return true

func _update_equipment_slot_visual(slot_id):
	# Visual update for equipment slots
	pass

func _show_tooltip(item_id):
	if tooltip_instance and inventory_data.has(item_id):
		var item_data = inventory_data[item_id]
		tooltip_instance.update_content(item_data)
		tooltip_instance.visible = true

func load_inventory(data):
	# Clear current inventory
	for item_id in inventory_data.keys():
		remove_item(item_id)
	
	# Load new inventory data
	for item_id in data:
		add_item_at(item_id, data[item_id], data[item_id].grid_position)
	
	# Update equipped items
	# This would need to be handled separately but similarly
