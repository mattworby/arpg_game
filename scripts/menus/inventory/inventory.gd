extends Control

signal inventory_changed(data)

const INVENTORY_WIDTH_PERCENT = 0.35
const GRID_SIZE = Vector2(10, 4)
const CELL_SIZE = 32

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

var slot_paths = {
	EquipSlot.HELMET: "InventoryWindow/EquipmentPanel/MiddleSlots/HelmetSlot",
	EquipSlot.ARMOR: "InventoryWindow/EquipmentPanel/MiddleSlots/Armour/ArmorSlot",
	EquipSlot.WEAPON: "InventoryWindow/EquipmentPanel/WeaponSlot",
	EquipSlot.SHIELD: "InventoryWindow/EquipmentPanel/ShieldSlot",
	EquipSlot.GLOVES: "InventoryWindow/EquipmentPanel/GlovesSlot",
	EquipSlot.BELT: "InventoryWindow/EquipmentPanel/MiddleSlots/BeltSlot",
	EquipSlot.BOOTS: "InventoryWindow/EquipmentPanel/BootsSlot",
	EquipSlot.AMULET: "InventoryWindow/EquipmentPanel/AmuletSlot",
	EquipSlot.RING_LEFT: "InventoryWindow/EquipmentPanel/LeftRingSlot",
	EquipSlot.RING_RIGHT: "InventoryWindow/EquipmentPanel/RightRingSlot"
}

var inventory_data = {}
var equipped_items = {} 
var dragging_item = null
var drag_start_position = Vector2()
var drag_start_grid_pos = Vector2()
var original_parent = null

var tooltip_instance = null
var tooltip_scene = preload("res://scenes/menus/inventory/item_tooltip.tscn")

func _ready():
	var inventory_grid = $InventoryWindow/InventoryPanel/InventoryGrid
	inventory_grid.custom_minimum_size = Vector2(GRID_SIZE.x * CELL_SIZE, GRID_SIZE.y * CELL_SIZE)
	
	inventory_grid.add_theme_constant_override("margin_top", 0)
	inventory_grid.add_theme_constant_override("margin_left", 0)
	inventory_grid.add_theme_constant_override("margin_right", 0)
	inventory_grid.add_theme_constant_override("margin_bottom", 0)
	inventory_grid.add_theme_constant_override("h_separation", 0)
	inventory_grid.add_theme_constant_override("v_separation", 0)
	
	for slot_id in slot_paths:
		var slot = get_node(slot_paths[slot_id])
		if slot:
			slot.connect("gui_input", _on_equipment_slot_input.bind(slot, slot_id))
	
	tooltip_instance = tooltip_scene.instantiate()
	tooltip_instance.visible = false
	
	_add_test_items()

func _add_test_items():
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
	
	add_item_at("wooden_shield", test_items["wooden_shield"], Vector2(0, 0))
	add_item_at("chainmail", test_items["chainmail"], Vector2(3, 0))
	add_item_at("horned_helmet", test_items["horned_helmet"], Vector2(6, 0))
	add_item_at("leather_gloves", test_items["leather_gloves"], Vector2(0, 2))
	add_item_at("gold_ring", test_items["gold_ring"], Vector2(8, 0))

func toggle_inventory():
	visible = !visible
	
	if visible and !tooltip_instance.is_inside_tree():
		add_child(tooltip_instance)

func _process(_delta):
	if tooltip_instance and tooltip_instance.visible:
		tooltip_instance.global_position = get_global_mouse_position() + Vector2(15, 15)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if dragging_item:
			dragging_item.global_position = get_global_mouse_position() - dragging_item.size / 2

func add_item(item_id, quantity=1):
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var grid_pos = Vector2(x, y)
			if can_place_item_at(item_id, grid_pos):
				return add_item_at(item_id, inventory_data[item_id], grid_pos)
	return false

func add_item_at(item_id, item_data, grid_position):
	if !inventory_data.has(item_id):
		inventory_data[item_id] = item_data
		inventory_data[item_id]["grid_position"] = grid_position
		
		var item_instance = create_item_instance(item_id, item_data)
		
		$InventoryWindow/InventoryPanel/InventoryGrid.add_child(item_instance)
		
		item_instance.position = Vector2(
			grid_position.x * CELL_SIZE,
			grid_position.y * CELL_SIZE
		)
		
		print(item_instance.size)
		
		emit_signal("inventory_changed", inventory_data)
		return true
	
	return false

func create_item_instance(item_id, item_data):
	var item_instance = ColorRect.new()
	item_instance.name = item_id
	item_instance.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var hue = randf()
	item_instance.color = Color.from_hsv(hue, 0.7, 0.8, 1.0)

	item_instance.custom_minimum_size = Vector2(item_data.grid_size.x * CELL_SIZE, item_data.grid_size.y * CELL_SIZE)
	item_instance.size = item_instance.custom_minimum_size
	
	var label = Label.new()
	label.text = item_data.name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	item_instance.add_child(label)
	
	item_instance.connect("gui_input", _on_item_gui_input.bind(item_instance, item_id))
	
	return item_instance

func can_place_item_at(item_id, grid_position):
	var item_data = inventory_data.get(item_id)
	if !item_data:
		return false
		
	var item_size = item_data.grid_size
	
	if grid_position.x < 0 or grid_position.y < 0:
		return false
	if grid_position.x + item_size.x > GRID_SIZE.x:
		return false
	if grid_position.y + item_size.y > GRID_SIZE.y:
		return false
	
	for x in range(item_size.x):
		for y in range(item_size.y):
			var check_pos = grid_position + Vector2(x, y)
			for other_id in inventory_data:
				if other_id == item_id:
					continue
				
				var other_data = inventory_data[other_id]
				var other_pos = other_data.grid_position
				var other_size = other_data.grid_size
				
				if check_pos.x >= other_pos.x and check_pos.x < other_pos.x + other_size.x and \
				   check_pos.y >= other_pos.y and check_pos.y < other_pos.y + other_size.y:
					return false
	
	return true

func remove_item(item_id):
	if inventory_data.has(item_id):
		var item_node = $InventoryPanel/InventoryGrid.get_node_or_null(item_id)
		if item_node:
			item_node.queue_free()
		
		inventory_data.erase(item_id)
		
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
				dragging_item = item_instance
				drag_start_position = item_instance.global_position
				drag_start_grid_pos = inventory_data[item_id].grid_position
				original_parent = item_instance.get_parent()
				
				original_parent.remove_child(item_instance)
				add_child(item_instance)
				
				_show_tooltip(item_id)
			else:
				if dragging_item and dragging_item == item_instance:
					_handle_item_drop(item_instance, item_id)
					dragging_item = null
					
					if tooltip_instance:
						tooltip_instance.visible = false
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_try_equip_item(item_id)

func _handle_item_drop(item_instance, item_id):
	var item_data = inventory_data[item_id]
	var drop_pos = get_global_mouse_position()
	
	for slot_id in slot_paths:
		var slot = get_node(slot_paths[slot_id])
		if slot and slot.get_global_rect().has_point(drop_pos):
			# Try to equip item to this slot
			if _can_equip_to_slot(item_id, slot_id):
				_equip_item(item_id, slot_id)
				return
	
	if $InventoryWindow/InventoryPanel/InventoryGrid.get_global_rect().has_point(drop_pos):
		var local_pos = $InventoryWindow/InventoryPanel/InventoryGrid.get_local_mouse_position()
		var grid_pos = pixel_to_grid(local_pos)
		
		if grid_pos != drag_start_grid_pos and can_place_item_at(item_id, grid_pos):
			inventory_data[item_id].grid_position = grid_pos
			
			if item_instance.get_parent() != $InventoryWindow/InventoryPanel/InventoryGrid:
				remove_child(item_instance)
				$InventoryWindow/InventoryPanel/InventoryGrid.add_child(item_instance)
			
			item_instance.position = Vector2(
				grid_pos.x * CELL_SIZE,
				grid_pos.y * CELL_SIZE
			)
			emit_signal("inventory_changed", inventory_data)
		else:
			if item_instance.get_parent() != original_parent:
				remove_child(item_instance)
				original_parent.add_child(item_instance)
			
			item_instance.position = Vector2(
				drag_start_grid_pos.x * CELL_SIZE,
				drag_start_grid_pos.y * CELL_SIZE
			)
	else:
		if item_instance.get_parent() != original_parent:
			remove_child(item_instance)
			original_parent.add_child(item_instance)
		
		item_instance.position = Vector2(
			drag_start_grid_pos.x * CELL_SIZE,
			drag_start_grid_pos.y * CELL_SIZE
		)

func _on_equipment_slot_input(event, slot, slot_id):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		if equipped_items.has(slot_id):
			var item_id = equipped_items[slot_id]
			_unequip_item(slot_id)

func _try_equip_item(item_id):
	var item_data = inventory_data[item_id]
	
	for slot_id in item_data.valid_slots:
		if _can_equip_to_slot(item_id, slot_id):
			_equip_item(item_id, slot_id)
			return true
	
	return false

func _can_equip_to_slot(item_id, slot_id):
	var item_data = inventory_data[item_id]
	
	if item_data.valid_slots.has(slot_id):
		if !equipped_items.has(slot_id):
			return true
	
	return false

func _equip_item(item_id, slot_id):
	var item_data = inventory_data[item_id]
	var item_instance = $InventoryPanel/InventoryGrid.get_node_or_null(item_id)
	
	if !item_instance:
		return false
	
	if equipped_items.has(slot_id):
		_unequip_item(slot_id)
	
	$InventoryPanel/InventoryGrid.remove_child(item_instance)
	
	var slot_node = get_node(slot_paths[slot_id])
	if slot_node:
		slot_node.add_child(item_instance)
		item_instance.position = Vector2.ZERO
		item_instance.size = slot_node.size
		
		equipped_items[slot_id] = item_id
		emit_signal("inventory_changed", inventory_data)
		return true
	
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
	
	var found_space = false
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var grid_pos = Vector2(x, y)
			if can_place_item_at(item_id, grid_pos):
				item_data.grid_position = grid_pos
				found_space = true
				break
		if found_space:
			break
	
	if !found_space:
		return false
	
	slot_node.remove_child(item_instance)
	
	$InventoryPanel/InventoryGrid.add_child(item_instance)
	item_instance.custom_minimum_size = Vector2(item_data.grid_size.x * CELL_SIZE, item_data.grid_size.y * CELL_SIZE)
	item_instance.size = item_instance.custom_minimum_size
	item_instance.position = grid_to_pixel(item_data.grid_position)
	
	equipped_items.erase(slot_id)
	emit_signal("inventory_changed", inventory_data)
	return true

func _update_equipment_slot_visual(slot_id):
	pass

func _show_tooltip(item_id):
	if tooltip_instance and inventory_data.has(item_id):
		var item_data = inventory_data[item_id]
		tooltip_instance.update_content(item_data)
		tooltip_instance.visible = true

func load_inventory(data):
	for item_id in inventory_data.keys():
		remove_item(item_id)
	
	for item_id in data:
		add_item_at(item_id, data[item_id], data[item_id].grid_position)
