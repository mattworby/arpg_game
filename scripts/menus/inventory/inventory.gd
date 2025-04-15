extends Control

signal inventory_changed(data)

const INVENTORY_WIDTH_PERCENT = 0.35
const GRID_SIZE = Vector2(12, 6)
const CELL_SIZE = 32

enum EquipSlot { HELMET, ARMOR, WEAPON, SHIELD, GLOVES, BELT, BOOTS, AMULET, RING_LEFT, RING_RIGHT }

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
var dragging_item_data = null
var drag_start_position = Vector2()
var drag_start_grid_pos = Vector2()
var original_parent = null

var drag_origin_type = ""
var drag_origin_slot_id = -1

var tooltip_instance = null
var tooltip_scene = preload("res://scenes/menus/inventory/item_tooltip.tscn")

@onready var grid_highlight_rect: ColorRect = $InventoryWindow/InventoryPanel/GridHighlightRect
@onready var inventory_grid_node = $InventoryWindow/InventoryPanel/InventoryGrid

const VALID_HIGHLIGHT_COLOR = Color(0.2, 1.0, 0.2, 0.35)
const INVALID_HIGHLIGHT_COLOR = Color(1.0, 0.2, 0.2, 0.35)
const SLOT_HIGHLIGHT_COLOR = Color(0.5, 1.0, 0.5, 0.5)

func _ready():
	inventory_grid_node.custom_minimum_size = Vector2(GRID_SIZE.x * CELL_SIZE, GRID_SIZE.y * CELL_SIZE)
	
	if inventory_grid_node.has_method("set_grid_parameters"):
		inventory_grid_node.set_grid_parameters(GRID_SIZE, CELL_SIZE)
	else:
		printerr("InventoryGrid node does not have set_grid_parameters method!")
	
	for slot_id in slot_paths:
		var slot = get_node_or_null(slot_paths[slot_id])
		if slot:
			slot.connect("gui_input", _on_equipment_slot_input.bind(slot, slot_id))
		else:
			printerr("Equipment slot node not found: ", slot_paths[slot_id])
	
	tooltip_instance = tooltip_scene.instantiate()
	tooltip_instance.visible = false
	
	_add_test_items()

func _add_test_items():
	var test_items = {
		"wooden_shield": {
			"name": "Wooden Shield",
			"type": "shield",
			"grid_size": Vector2(2, 3),
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
		"mail_gloves": {
			"name": "Mail Gloves",
			"type": "gloves",
			"grid_size": Vector2(2, 2),
			"valid_slots": [EquipSlot.GLOVES],
			"texture": "res://assets/items/leather_gloves.png",
			"stats": {"defense": 5}
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
	add_item_at("leather_gloves", test_items["leather_gloves"], Vector2(0, 3))
	add_item_at("mail_gloves", test_items["mail_gloves"], Vector2(3, 3))
	add_item_at("gold_ring", test_items["gold_ring"], Vector2(8, 0))

func toggle_inventory():
	visible = !visible
	
	if visible:
		if !tooltip_instance.is_inside_tree():
			add_child(tooltip_instance)
		tooltip_instance.visible = false
	else:
		if tooltip_instance and tooltip_instance.is_inside_tree():
			tooltip_instance.visible = false
			
func _input(event: InputEvent):
	var handled = false
	if dragging_item and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not tooltip_instance.visible:
		print("Drag End Detected for item: %s (Origin: %s)" % [dragging_item.name, drag_origin_type])

		if drag_origin_type == "grid":
			handled = _handle_item_drop(dragging_item, dragging_item.name)
		elif drag_origin_type == "slot":
			handled = _handle_item_drop_from_slot(dragging_item, dragging_item.name, drag_origin_slot_id)
		else:
			printerr("Drag ended with unknown origin type!")
			if is_instance_valid(original_parent):
				if dragging_item.get_parent() == self: 
					dragging_item.reparent(original_parent)
					dragging_item.position = grid_to_pixel(drag_start_grid_pos)
		_reset_highlights()
		
		if handled:
			dragging_item = null
			dragging_item_data = null
			drag_origin_type = ""
			drag_origin_slot_id = -1
			original_parent = null

func _process(_delta):
	if tooltip_instance and tooltip_instance.visible:
		tooltip_instance.global_position = get_global_mouse_position() + Vector2(15, 15)

	if dragging_item:
		dragging_item.global_position = get_global_mouse_position() - dragging_item.size / 2

		var mouse_pos = get_global_mouse_position()
		var handled_highlight = false

		for slot_id_reset in slot_paths:
			var slot_node_reset = get_node_or_null(slot_paths[slot_id_reset])
			if slot_node_reset:
				slot_node_reset.modulate = Color(1, 1, 1, 1)

		for slot_id in slot_paths:
			var slot_node = get_node_or_null(slot_paths[slot_id])
			if slot_node and slot_node.get_global_rect().has_point(mouse_pos):
				if _can_equip_to_slot(dragging_item.name, slot_id):
					slot_node.modulate = SLOT_HIGHLIGHT_COLOR
					handled_highlight = true
					if grid_highlight_rect: grid_highlight_rect.visible = false
					break
				else:
					slot_node.modulate = Color(1, 0.5, 0.5, 0.5)
					handled_highlight = true
					break

		var grid_global_rect = inventory_grid_node.get_global_rect()
		if not handled_highlight and grid_global_rect.has_point(mouse_pos):
			if grid_highlight_rect and dragging_item_data:
				var local_pos = mouse_pos - grid_global_rect.position

				var item_center_offset = dragging_item.size / 2
				var potential_top_left_pixel = local_pos - item_center_offset
				var potential_grid_pos = pixel_to_grid(potential_top_left_pixel)

				var is_valid_placement = can_place_item_at(dragging_item.name, dragging_item_data, potential_grid_pos)

				grid_highlight_rect.position = grid_to_pixel(potential_grid_pos)
				grid_highlight_rect.size = dragging_item.size
				grid_highlight_rect.color = VALID_HIGHLIGHT_COLOR if is_valid_placement else INVALID_HIGHLIGHT_COLOR
				grid_highlight_rect.visible = true
				handled_highlight = true
			elif not dragging_item_data:
				printerr("Cannot show grid highlight - missing dragging_item_data")

		if not handled_highlight and grid_highlight_rect:
			grid_highlight_rect.visible = false

	else:
		if grid_highlight_rect and grid_highlight_rect.visible:
			grid_highlight_rect.visible = false

		for slot_id_reset in slot_paths:
			var slot_node_reset = get_node_or_null(slot_paths[slot_id_reset])
			if slot_node_reset and slot_node_reset.modulate != Color(1, 1, 1, 1):
				slot_node_reset.modulate = Color(1, 1, 1, 1)

func add_item(item_id, quantity=1):
	var db = get_node_or_null("/root/ItemDatabase")
	var item_data = null
	if db: item_data = db.get_item(item_id)
	if not item_data:
		printerr("Cannot add item: Data not found for ", item_id); return false
	for y in range(int(GRID_SIZE.y)):
		for x in range(int(GRID_SIZE.x)):
			var grid_pos = Vector2(x, y)
			if can_place_item_at(item_id, item_data, grid_pos):
				return add_item_at(item_id, item_data, grid_pos)
	print("Inventory full."); 
	return false

func add_item_at(item_id: String, item_data: Dictionary, grid_position: Vector2):
	if not item_data: 
		printerr("Tried to add item with null data: ", item_id)
		return false
	if inventory_data.has(item_id): 
		printerr("Item already exists: ", item_id)
		return false
	if not can_place_item_at(item_id, item_data, grid_position):
		print("Cannot place item %s at %s" % [item_data.get("name", item_id), grid_position])
		return false
	inventory_data[item_id] = item_data.duplicate(true)
	inventory_data[item_id]["grid_position"] = grid_position
	var item_instance = create_item_instance(item_id, item_data)
	inventory_grid_node.add_child(item_instance)
	item_instance.position = grid_to_pixel(grid_position)
	emit_signal("inventory_changed", inventory_data) 
	return true

func create_item_instance(item_id: String, item_data: Dictionary) -> Control:
	var item_instance = ColorRect.new()
	item_instance.name = item_id
	item_instance.mouse_filter = Control.MOUSE_FILTER_STOP
	var item_grid_size = item_data.get("grid_size", Vector2(1, 1))
	item_instance.custom_minimum_size = Vector2(item_grid_size.x * CELL_SIZE, item_grid_size.y * CELL_SIZE)
	item_instance.size = item_instance.custom_minimum_size
	item_instance.color = Color.from_hsv(randf(), 0.7, 0.8, 1.0)
	var label = Label.new()
	label.text = item_data.get("name", "N/A")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT); item_instance.add_child(label)
	item_instance.connect("gui_input", _on_item_gui_input.bind(item_instance, item_id))
	item_instance.connect("mouse_entered", _on_item_mouse_entered.bind(item_data))
	item_instance.connect("mouse_exited", _on_item_mouse_exited)
	return item_instance

func can_place_item_at(item_id_to_place: String, item_data_to_place: Dictionary, grid_position: Vector2, ignore_list: Array = []) -> bool:
	if not item_data_to_place or not item_data_to_place.has("grid_size"): return false
	var item_size = item_data_to_place.grid_size
	var grid_pos_i = Vector2i(int(grid_position.x), int(grid_position.y))
	var item_size_i = Vector2i(int(item_size.x), int(item_size.y))
	if grid_pos_i.x < 0 or grid_pos_i.y < 0: return false
	if grid_pos_i.x + item_size_i.x > int(GRID_SIZE.x): return false
	if grid_pos_i.y + item_size_i.y > int(GRID_SIZE.y): return false
	var target_rect = Rect2i(grid_pos_i, item_size_i)

	for other_id in inventory_data:
		if other_id == item_id_to_place or other_id in ignore_list: 
			continue
		var other_data = inventory_data[other_id]
		if not other_data or not other_data.has("grid_position") or not other_data.has("grid_size"): 
			continue
		var other_pos = other_data.grid_position; var other_size = other_data.grid_size
		var other_pos_i = Vector2i(int(other_pos.x), int(other_pos.y))
		var other_size_i = Vector2i(int(other_size.x), int(other_size.y))
		var other_rect = Rect2i(other_pos_i, other_size_i)
		if target_rect.intersects(other_rect): return false
	return true

func remove_item(item_id: String):
	if inventory_data.has(item_id):
		var _node_removed = false
		var item_node = inventory_grid_node.get_node_or_null(item_id)
		if item_node:
			item_node.queue_free() 
			_node_removed = true
		else: 
			item_node = get_node_or_null(item_id) 
			if item_node and item_node == dragging_item: 
				item_node.queue_free()
				if dragging_item == item_node: 
					dragging_item = null 
					_node_removed = true
			else: 
				for slot_id_check in slot_paths: 
					var slot_node = get_node_or_null(slot_paths[slot_id_check]); 
					if slot_node: item_node = slot_node.get_node_or_null(item_id);
					if item_node: 
						item_node.queue_free()
						_node_removed = true; 
					break
		inventory_data.erase(item_id)
		for slot_id in equipped_items.keys(): if equipped_items[slot_id] == item_id: equipped_items.erase(slot_id); _update_equipment_slot_visual(slot_id); break
		emit_signal("inventory_changed", inventory_data); 
		return true
	return false

func has_item(item_id, quantity=1): return inventory_data.has(item_id)

func grid_to_pixel(grid_pos):
	return Vector2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE)

func pixel_to_grid(pixel_pos):
	return Vector2(floor(pixel_pos.x / CELL_SIZE), floor(pixel_pos.y / CELL_SIZE))

func _on_item_gui_input(event: InputEvent, item_instance: Control, item_id: String):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not inventory_data.has(item_id):
					printerr("Cannot start drag: Item '%s' not found in inventory data." % item_id)
					return
				var item_data = inventory_data[item_id]

				print("Drag Start from GRID: ", item_id)
				dragging_item = item_instance
				dragging_item_data = item_data
				drag_start_grid_pos = item_data.grid_position
				drag_start_position = item_instance.global_position
				original_parent = item_instance.get_parent()

				drag_origin_type = "grid"
				drag_origin_slot_id = -1

				_hide_tooltip()

				if is_instance_valid(original_parent) and original_parent != self:
					original_parent.remove_child(item_instance)
					add_child(item_instance)
					item_instance.global_position = get_global_mouse_position() - item_instance.size / 2

			else:
				var handled = false
				if dragging_item and dragging_item == item_instance:
					print("Drag End Detected for item: %s (Origin: %s)" % [item_id, drag_origin_type])

					if drag_origin_type == "grid":
						handled = _handle_item_drop(item_instance, item_id)
					elif drag_origin_type == "slot":
						handled = _handle_item_drop_from_slot(item_instance, item_id, drag_origin_slot_id)
					else:
						printerr("Drag ended with unknown origin type!")
						if is_instance_valid(original_parent):
							if item_instance.get_parent() == self: 
								item_instance.reparent(original_parent)
								item_instance.position = grid_to_pixel(drag_start_grid_pos)
					_reset_highlights()
					
					if handled:
						dragging_item = null
						dragging_item_data = null
						drag_origin_type = ""
						drag_origin_slot_id = -1
						original_parent = null

func _handle_item_drop(item_instance: Control, item_id: String):
	var item_data_local = dragging_item_data
	if not item_data_local:
		printerr("Item data lost during drag for: ", item_id)
		if is_instance_valid(item_instance) and item_instance.get_parent() == self:
			remove_child(item_instance); item_instance.queue_free()
		_reset_highlights()
		return false

	var drop_pos = get_global_mouse_position()
	var handled = false
	var swapped_item = false

	for slot_id in slot_paths:
		var slot_node = get_node_or_null(slot_paths[slot_id])
		if slot_node and slot_node.get_global_rect().has_point(drop_pos):
			print("Checking drop from grid onto slot: ", slot_id)
			if item_data_local.get("valid_slots", []).has(slot_id):
				print("  -> Slot type is valid.")
				if equipped_items.has(slot_id):
					print("  -> Slot is OCCUPIED by '%s'. Attempting swap..." % equipped_items[slot_id])
					var item_id_equipped = equipped_items[slot_id]
					var item_instance_equipped = slot_node.get_node_or_null(item_id_equipped)
					var db = get_node_or_null("/root/ItemDatabase")
					var item_data_equipped = db.get_item(item_id_equipped) if db else null
					
					if is_instance_valid(item_instance_equipped) and item_data_equipped:
						print("    -> Proceeding with swap.")

						equipped_items[slot_id] = item_id

						if item_instance.get_parent() == self: 
							remove_child(item_instance)
						slot_node.add_child(item_instance)
						item_instance.position = Vector2.ZERO
						item_instance.size = slot_node.size
						item_instance.mouse_filter = Control.MOUSE_FILTER_PASS

						slot_node.remove_child(item_instance_equipped)

						dragging_item = item_instance_equipped
						dragging_item_data = item_data_equipped
						drag_origin_type = "slot" 
						drag_origin_slot_id = slot_id
						original_parent = slot_node                
						drag_start_position = item_instance_equipped.global_position
						drag_start_grid_pos = Vector2(-1,-1)

						add_child(item_instance_equipped)
						item_instance_equipped.global_position = get_global_mouse_position() - item_instance_equipped.size / 2
						item_instance_equipped.mouse_filter = Control.MOUSE_FILTER_STOP 
						inventory_data[item_id_equipped] = item_data_local.duplicate(true)
						if inventory_data.has(item_id): 
							inventory_data.erase(item_id)
						emit_signal("inventory_changed", inventory_data)
						

						print("    -> Swap successful, picked up '%s'." % item_id_equipped)
						handled = true
						swapped_item = true
					else:
						print("    -> Swap failed: Cannot find instance or data for equipped item '%s'." % item_id_equipped)

				elif _can_equip_to_slot(item_id, slot_id):
					print("  -> Slot is EMPTY and valid. Equipping...")
					if item_instance.get_parent() == self: remove_child(item_instance)
					if _equip_item(item_id, item_instance, slot_id):
						handled = true
					else:
						if not item_instance.is_inside_tree(): add_child(item_instance) 

			else: 
				print("  -> Slot type is invalid for this item.")
			break
			
	var grid_global_rect = inventory_grid_node.get_global_rect()
	if not handled and grid_global_rect.has_point(drop_pos):
		var local_pos = drop_pos - grid_global_rect.position
		var item_center_offset = item_instance.size / 2
		var potential_top_left_pixel = local_pos - item_center_offset
		var potential_grid_pos = pixel_to_grid(potential_top_left_pixel)
		
		if potential_grid_pos != drag_start_grid_pos and can_place_item_at(item_id, item_data_local, potential_grid_pos):
			var target_parent = inventory_grid_node
			if is_instance_valid(target_parent):
				if item_instance.get_parent() == self:
					item_instance.reparent(target_parent) 
				elif not item_instance.is_inside_tree():
					target_parent.add_child(item_instance)
				elif item_instance.get_parent() != target_parent:
					item_instance.reparent(target_parent)

				item_instance.position = grid_to_pixel(potential_grid_pos)
				emit_signal("inventory_changed", inventory_data)
				handled = true
			else:
				printerr("InventoryGrid node invalid! Cannot reparent item %s" % item_id)
				if is_instance_valid(item_instance): 
					item_instance.queue_free()
				if inventory_data.has(item_id): 
					inventory_data.erase(item_id)
				emit_signal("inventory_changed", inventory_data)
			_reset_highlights()
		else:
			if potential_grid_pos == drag_start_grid_pos:
				print("  -> Grid position same as start.")
			elif not is_valid_grid_position(potential_grid_pos, item_data_local.get("grid_size", Vector2(1,1))):
				print("  -> Invalid grid drop position (Out of Bounds): ", potential_grid_pos)
			else:
				print("Occupied")
	if not handled:
		var target_parent = original_parent
		if is_instance_valid(target_parent):
			print("invalid slot")
		else: 
			printerr("Original parent invalid on snap back for %s" % item_id)
			if is_instance_valid(item_instance): 
				item_instance.queue_free()
			if inventory_data.has(item_id): 
				inventory_data.erase(item_id)
			emit_signal("inventory_changed", inventory_data)
		return false
	return not swapped_item

func _on_equipment_slot_input(event: InputEvent, slot_node: Panel, slot_id: int):
	if event is InputEventMouseButton:
		if not equipped_items.has(slot_id): 
			return

		var item_id = equipped_items[slot_id]
		var item_instance = slot_node.get_node_or_null(item_id)
		
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not is_instance_valid(item_instance):
				printerr("Cannot start drag from slot %s: Item instance '%s' not found!" % [slot_id, item_id])
				return

			var db = get_node_or_null("/root/ItemDatabase"); var item_data_local = db.get_item(item_id) if db else null
			if not item_data_local:
				printerr("Cannot start drag from slot %s: Failed to get data for '%s'." % [slot_id, item_id])
				return

			print("Drag Start from SLOT: %s (Item: %s)" % [slot_id, item_id])
			dragging_item = item_instance
			dragging_item_data = item_data_local
			drag_start_position = item_instance.global_position
			original_parent = slot_node

			drag_origin_type = "slot"
			drag_origin_slot_id = slot_id

			_hide_tooltip()

			if is_instance_valid(original_parent):
				original_parent.remove_child(item_instance)
				add_child(item_instance)
				item_instance.global_position = get_global_mouse_position() - item_instance.size / 2
			else:
				printerr("Cannot start drag: Slot node parent is invalid?")
				dragging_item = null
				dragging_item_data = null
				drag_origin_type = ""
				drag_origin_slot_id = -1
				return

func _can_equip_to_slot(item_id: String, slot_id: int) -> bool:
	if not slot_paths.has(slot_id):
		return false

	if not inventory_data.has(item_id):
		if not dragging_item_data or dragging_item.name != item_id:
			return false

	var item_data_source = inventory_data.get(item_id, dragging_item_data)
	if not item_data_source:
		return false

	var valid_slots_for_item = item_data_source.get("valid_slots", [])
	if not valid_slots_for_item.has(slot_id):
		return false

	if equipped_items.has(slot_id):
		return false

	return true

func _equip_item(item_id: String, item_instance: Control, slot_id: int) -> bool:
	if not inventory_data.has(item_id): printerr(" Equip Fail: Item '%s' data not found." % item_id); return false
	if not is_instance_valid(item_instance): printerr(" Equip Fail: Passed instance invalid."); return false
	var slot_node_path = slot_paths.get(slot_id); if not slot_node_path: printerr(" Equip Fail: No path for slot %s" % slot_id); return false
	var slot_node = get_node_or_null(slot_node_path); if not is_instance_valid(slot_node): printerr(" Equip Fail: Slot node not found: %s" % slot_node_path); return false
	print("  Equip Info: Found instance: %s, Found slot: %s" % [item_instance, slot_node])

	if equipped_items.has(slot_id):
		print("  Equip Info: Slot %s occupied, attempting swap..." % slot_id)
		if not _unequip_item(slot_id): 
			printerr(" Equip Fail: Swap failed.")
			return false

	print("  Equip Info: Performing equip steps...")
	var current_parent = item_instance.get_parent()
	if is_instance_valid(current_parent):
		print("  Equip Info: Removing '%s' from parent: %s" % [item_id, current_parent.name])
		current_parent.remove_child(item_instance)

	if inventory_data.has(item_id):
		inventory_data.erase(item_id)
		print("  Equip Info: Removed '%s' from inventory_data." % item_id)

	print("  Equip Info: Adding '%s' as child to slot: %s" % [item_id, slot_node.name])
	slot_node.add_child(item_instance)
	item_instance.position = Vector2.ZERO
	item_instance.size = slot_node.size

	item_instance.mouse_filter = Control.MOUSE_FILTER_PASS
	print("  Equip Info: Set mouse_filter to PASS for equipped item.")

	equipped_items[slot_id] = item_id
	print("  Equip Info: Updated equipped_items[%s] = %s" % [slot_id, item_id])

	emit_signal("inventory_changed", inventory_data)
	print("---> Equip Success: '%s' to slot %s" % [item_id, slot_id])
	return true

func _unequip_item(slot_id: int, p_target_grid_pos: Vector2 = Vector2(-1,-1)) -> bool:
	print("---> Attempting _unequip_item: slot_id=%s, target_pos=%s" % [slot_id, p_target_grid_pos])

	if not equipped_items.has(slot_id): 
		print(" Unequip Fail: Slot empty.")
		return false
	var item_id = equipped_items[slot_id]
	print("  Unequip Info: Item: '%s'" % item_id)

	var db = get_node_or_null("/root/ItemDatabase")
	var item_data_local = db.get_item(item_id) if db else null
	if not item_data_local: 
		printerr(" Unequip Fail: No data for '%s'." % item_id)
		return false
	print("  Unequip Info: Found item data.")

	var final_grid_pos = p_target_grid_pos
	if final_grid_pos == Vector2(-1,-1): 
		print("  Unequip Info: No target position provided, finding first available...")
		var found_space = false
		for y in range(int(GRID_SIZE.y)):
			for x in range(int(GRID_SIZE.x)):
				var grid_pos = Vector2(x, y)
				if can_place_item_at(item_id, item_data_local, grid_pos):
					final_grid_pos = grid_pos
					found_space = true
					break
			if found_space: break
		if not found_space:
			print(" Unequip Fail: Inventory full (when searching).")
			return false
		print("  Unequip Info: Found available space at: %s" % final_grid_pos)
	else:
		print("  Unequip Info: Using provided target position: %s" % final_grid_pos)


	var slot_node = get_node_or_null(slot_paths.get(slot_id))
	if not is_instance_valid(slot_node): 
		printerr(" Unequip Fail: Slot node %s invalid." % slot_id)
		return false
	var item_instance = slot_node.get_node_or_null(item_id)
	if not is_instance_valid(item_instance): 
		printerr(" Unequip Fail: Instance '%s' not in slot." % item_id)
		equipped_items.erase(slot_id)
		emit_signal("inventory_changed", inventory_data)
		return false
	print("  Unequip Info: Found instance '%s' in slot '%s'" % [item_instance.name, slot_node.name])

	print("  Unequip Info: Removing '%s' from slot '%s'" % [item_id, slot_node.name])
	slot_node.remove_child(item_instance)
	equipped_items.erase(slot_id)
	print("  Unequip Info: Removed item from equipped_items for slot %s" % slot_id)

	inventory_data[item_id] = item_data_local.duplicate(true)
	inventory_data[item_id]["grid_position"] = final_grid_pos
	print("  Unequip Info: Added '%s' back to inventory_data at pos %s" % [item_id, final_grid_pos])

	print("  Unequip Info: Adding '%s' back to inventory grid node." % item_id)
	inventory_grid_node.add_child(item_instance)

	item_instance.mouse_filter = Control.MOUSE_FILTER_STOP
	print("  Unequip Info: Set mouse_filter back to STOP for grid item.")

	var item_grid_size = item_data_local.get("grid_size", Vector2(1, 1))
	item_instance.custom_minimum_size = Vector2(item_grid_size.x * CELL_SIZE, item_grid_size.y * CELL_SIZE)
	item_instance.size = item_instance.custom_minimum_size
	item_instance.position = grid_to_pixel(final_grid_pos) 
	print("  Unequip Info: Set position to %s and size to %s" % [item_instance.position, item_instance.size])

	emit_signal("inventory_changed", inventory_data)
	print("---> Unequip Success: '%s' from slot %s to grid %s" % [item_id, slot_id, final_grid_pos])
	return true

func _update_equipment_slot_visual(slot_id):
	pass
	
func _on_item_mouse_entered(item_data):
	var drag_data = get_viewport().gui_get_drag_data()
	if drag_data:
		return

	if tooltip_instance and item_data:
		tooltip_instance.update_content(item_data)
		tooltip_instance.visible = true

func _on_item_mouse_exited():
	if tooltip_instance:
		tooltip_instance.visible = false
		
func _hide_tooltip():
	if tooltip_instance:
		tooltip_instance.visible = false

func _show_tooltip(item_data):
	if dragging_item: return
	if tooltip_instance and item_data:
		tooltip_instance.update_content(item_data)
		tooltip_instance.visible = true
		_process(0)
		
func _reset_highlights():
	if grid_highlight_rect:
		grid_highlight_rect.visible = false
	for slot_id in slot_paths:
		var slot_node = get_node_or_null(slot_paths[slot_id])
		if slot_node:
			slot_node.modulate = Color(1, 1, 1, 1)

func load_inventory(data):
	for item_id in inventory_data.keys():
		remove_item(item_id)
	
	for item_id in data:
		add_item_at(item_id, data[item_id], data[item_id].grid_position)
		

func _handle_item_drop_from_slot(item_instance: Control, item_id: String, origin_slot_id: int):
	var item_data_local = dragging_item_data
	if not item_data_local:
		printerr("Item data lost during drag from slot for: ", item_id)
		if is_instance_valid(item_instance) and item_instance.get_parent() == self: remove_child(item_instance); item_instance.queue_free()
		_reset_highlights(); return

	var drop_pos = get_global_mouse_position()
	var handled = false
	var target_parent : Node = get_node_or_null(slot_paths[origin_slot_id])

	for target_slot_id in slot_paths:
		var target_slot_node = get_node_or_null(slot_paths[target_slot_id])
		if target_slot_node and target_slot_node.get_global_rect().has_point(drop_pos):
			print("Checking drop from slot %s onto slot %s" % [origin_slot_id, target_slot_id])

			if target_slot_id == origin_slot_id:
				target_parent = target_slot_node; handled = true

			elif item_data_local.get("valid_slots", []).has(target_slot_id):
				print("  -> Slot type is valid for dragged item.")
				if not equipped_items.has(target_slot_id):
					print("    -> Slot is empty. Moving item.")
					equipped_items.erase(origin_slot_id)
					equipped_items[target_slot_id] = item_id
					target_parent = target_slot_node; handled = true

				else:
					print("    -> Slot is OCCUPIED by '%s'. Attempting swap..." % equipped_items[target_slot_id])
					var item_id_equipped = equipped_items[target_slot_id]
					var item_instance_equipped = target_slot_node.get_node_or_null(item_id_equipped)
					var db = get_node_or_null("/root/ItemDatabase"); var item_data_equipped = db.get_item(item_id_equipped) if db else null

					if is_instance_valid(item_instance_equipped) and item_data_equipped and item_data_equipped.get("valid_slots", []).has(origin_slot_id):
						print("      -> Swap valid: '%s' can go to origin slot %s." % [item_id_equipped, origin_slot_id])
						equipped_items[target_slot_id] = item_id
						equipped_items.erase(origin_slot_id)

						if item_instance.get_parent() == self: remove_child(item_instance)
						target_slot_node.add_child(item_instance)
						item_instance.position = Vector2.ZERO; item_instance.size = target_slot_node.size
						item_instance.mouse_filter = Control.MOUSE_FILTER_PASS

						target_slot_node.remove_child(item_instance_equipped)

						dragging_item = item_instance_equipped
						dragging_item_data = item_data_equipped
						drag_origin_type = "slot"
						drag_origin_slot_id = target_slot_id
						original_parent = target_slot_node
						drag_start_position = item_instance_equipped.global_position
						drag_start_grid_pos = Vector2(-1,-1)

						add_child(item_instance_equipped)
						item_instance_equipped.global_position = get_global_mouse_position() - item_instance_equipped.size / 2
						item_instance_equipped.mouse_filter = Control.MOUSE_FILTER_STOP 
						handled = true
						target_parent = target_slot_node
						print("      -> Slot-to-slot swap successful, picked up '%s'." % item_id_equipped)
					else:
						print("      -> Swap invalid: Equipped item '%s' cannot go into origin slot %s." % [item_id_equipped, origin_slot_id])
						return false
			else:
				print("Invalid slot") 
				return false
			break

	var grid_global_rect = inventory_grid_node.get_global_rect()
	if not handled and grid_global_rect.has_point(drop_pos):
		var local_pos = drop_pos - grid_global_rect.position
		var item_center_offset = item_instance.size / 2
		var potential_top_left_pixel = local_pos - item_center_offset
		var potential_grid_pos = pixel_to_grid(potential_top_left_pixel)
		print("Checking drop from slot onto grid at target cell: ", potential_grid_pos)
		if can_place_item_at(item_id, item_data_local, potential_grid_pos):
			print("  -> Valid grid position. Moving from slot %s to grid %s" % [origin_slot_id, potential_grid_pos])
			if equipped_items.has(origin_slot_id): 
				equipped_items.erase(origin_slot_id)
			inventory_data[item_id] = item_data_local.duplicate(true)
			inventory_data[item_id]["grid_position"] = potential_grid_pos
			target_parent = inventory_grid_node
			handled = true
			print("  -> Set target_parent to InventoryGrid, handled=true")
		else:
			if not is_valid_grid_position(potential_grid_pos, item_data_local.get("grid_size", Vector2(1,1))):
				print("  -> Invalid grid drop position (Out of Bounds): ", potential_grid_pos)
			else: 
				print("Occupied")
			return false

	if is_instance_valid(target_parent):
		if item_instance.get_parent() == self: item_instance.reparent(target_parent)
		elif not item_instance.is_inside_tree(): target_parent.add_child(item_instance)
		elif item_instance.get_parent() != target_parent: item_instance.reparent(target_parent)

		if target_parent == inventory_grid_node:
			var final_grid_pos = inventory_data[item_id].grid_position
			item_instance.position = grid_to_pixel(final_grid_pos)
			var item_grid_size = item_data_local.get("grid_size", Vector2(1, 1))
			item_instance.custom_minimum_size = Vector2(item_grid_size.x * CELL_SIZE, item_grid_size.y * CELL_SIZE)
			item_instance.size = item_instance.custom_minimum_size
			item_instance.mouse_filter = Control.MOUSE_FILTER_STOP; print("  Reparent/Pos: Placed on grid. Set mouse_filter to STOP.")
		else:
			item_instance.position = Vector2.ZERO; item_instance.size = target_parent.size
			item_instance.mouse_filter = Control.MOUSE_FILTER_PASS; print("  Reparent/Pos: Placed in slot. Set mouse_filter to PASS.")
	else:
		printerr("Target parent node is invalid for item '%s'! Cannot place item." % item_id)

	emit_signal("inventory_changed", inventory_data)
	_reset_highlights()
	return true
	
func is_valid_grid_position(grid_pos: Vector2, item_size: Vector2) -> bool:
	if grid_pos.x < 0 or grid_pos.y < 0: return false
	if grid_pos.x + item_size.x > GRID_SIZE.x: return false
	if grid_pos.y + item_size.y > GRID_SIZE.y: return false
	return true
