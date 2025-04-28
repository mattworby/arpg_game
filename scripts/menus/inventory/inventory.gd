extends Control

@export var generate_test_items_on_ready: bool = true

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

var inventory_data: Dictionary = {}
var equipped_items: Dictionary = {}
var equipped_item_data: Dictionary = {}

var dragging_item_data = null
var drag_start_position = Vector2()
var is_carrying_item: bool = false
var carried_item: Control = null
var carried_item_data: Dictionary = {}
var carry_origin_type: String = ""
var carry_origin_info = null

var tooltip_instance = null
var tooltip_scene = preload("res://scenes/menus/inventory/item_tooltip.tscn")

@onready var grid_highlight_rect: ColorRect = $InventoryWindow/InventoryPanel/GridHighlightRect
@onready var inventory_grid_node: Control = $InventoryWindow/InventoryPanel/InventoryGrid
@onready var inventory_window_node: Panel = $InventoryWindow

const VALID_HIGHLIGHT_COLOR = Color(0.2, 1.0, 0.2, 0.35)
const INVALID_HIGHLIGHT_COLOR = Color(1.0, 0.2, 0.2, 0.35)
const VALID_HOVER_HIGHLIGHT_COLOR = Color(0.6, 1.0, 0.6, 0.6)

func _ready():
	inventory_grid_node.custom_minimum_size = Vector2(GRID_SIZE.x * CELL_SIZE, GRID_SIZE.y * CELL_SIZE)

	call_deferred("_setup_slot_connections")

	tooltip_instance = tooltip_scene.instantiate()
	tooltip_instance.visible = false

	if generate_test_items_on_ready:
		_generate_test_items()
	
func _setup_slot_connections():
	for slot_id in slot_paths:
		var slot = get_node_or_null(slot_paths[slot_id])
		if slot:
			var callable_to_connect = Callable(self, "_on_equipment_slot_input").bind(slot, slot_id)
			if not slot.is_connected("gui_input", callable_to_connect):
				slot.connect("gui_input", callable_to_connect)
		else:
			printerr("Equipment slot node not found (deferred): ", slot_paths[slot_id])

func _generate_test_items():
	print("Inventory: Generating test items...")
	clear_all_items()

func toggle_inventory():
	visible = !visible
	if not visible and is_carrying_item:
		_cancel_carry()
	if visible:
		if not tooltip_instance.is_inside_tree(): 
			add_child(tooltip_instance)
		tooltip_instance.visible = false
	else:
		if tooltip_instance and tooltip_instance.is_inside_tree(): tooltip_instance.visible = false

func _input(event: InputEvent):
	var handled_event = false

	if is_carrying_item and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if get_viewport().is_input_handled():
			return

		var mouse_pos = get_global_mouse_position()
		var placed_on_slot = false

		if not is_instance_valid(inventory_window_node) or not inventory_window_node.is_visible_in_tree():
			return

		for slot_id in slot_paths:
			var slot_node = get_node_or_null(slot_paths[slot_id])
			if is_instance_valid(slot_node) and slot_node.is_visible_in_tree():
				var slot_rect = slot_node.get_global_rect()
				if slot_rect.has_point(mouse_pos):
					print("Inventory _input: Click detected directly over Slot ID: ", slot_id, " Rect: ", slot_rect, " GlobalMousePos: ", mouse_pos)
					_handle_placement_click() 
					placed_on_slot = true
					handled_event = true
					break

		if not placed_on_slot:
			var window_rect = inventory_window_node.get_global_rect()
			var is_inside_window = window_rect.has_point(mouse_pos)

			if is_inside_window:
				var grid_panel = inventory_window_node.find_child("InventoryPanel")
				var is_over_grid_panel = false
				if is_instance_valid(grid_panel):
					is_over_grid_panel = grid_panel.get_global_rect().has_point(mouse_pos)

				if is_over_grid_panel:
					print("Inventory _input: Click detected on InventoryPanel background")
					_handle_placement_click()
					handled_event = true
				else:
					print("Inventory _input: Click inside window but not on slot/grid panel, canceling.")
					_cancel_carry()
					handled_event = true
			else:
				print("Inventory _input: Placement Click outside InventoryWindow bounds, canceling.")
				_cancel_carry()
				handled_event = true

	elif is_carrying_item and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if not get_viewport().is_input_handled():
			var mouse_pos = get_global_mouse_position()
			print("Inventory _input: Cancel Carry (Right Click) at GlobalPos=", mouse_pos)
			_cancel_carry()
			handled_event = true

	if handled_event:
		get_viewport().set_input_as_handled()

func _process(_delta):
	if tooltip_instance and tooltip_instance.visible:
		tooltip_instance.global_position = get_global_mouse_position() + Vector2(15, 15)

	if is_carrying_item and is_instance_valid(carried_item):
		carried_item.global_position = get_global_mouse_position() - carried_item.size / 2
		_update_highlights()
	elif grid_highlight_rect.visible:
		_reset_highlights()

func _update_highlights():
	if not is_carrying_item or not carried_item_data:
		_reset_highlights()
		return

	var mouse_pos = get_global_mouse_position()
	var handled_highlight = false

	for slot_id_reset in slot_paths:
		var slot_node_reset = get_node_or_null(slot_paths[slot_id_reset])
		if slot_node_reset:
			if _can_equip_to_slot(carried_item_data, slot_id_reset, true): 
				slot_node_reset.modulate = VALID_HIGHLIGHT_COLOR 
			else:
				slot_node_reset.modulate = Color(1, 1, 1, 1)

	for slot_id in slot_paths:
		var slot_node = get_node_or_null(slot_paths[slot_id])
		if slot_node and slot_node.get_global_rect().has_point(mouse_pos):
			if _can_place_carried_item_in_slot(slot_id):
				slot_node.modulate = VALID_HOVER_HIGHLIGHT_COLOR
			else:
				slot_node.modulate = INVALID_HIGHLIGHT_COLOR
			handled_highlight = true
			if grid_highlight_rect: grid_highlight_rect.visible = false
			break # Only one slot can be hovered

	var grid_global_rect = inventory_grid_node.get_global_rect()
	if not handled_highlight and grid_global_rect.has_point(mouse_pos):
		if grid_highlight_rect:
			var local_pos = mouse_pos - grid_global_rect.position
			var item_pixel_size = Vector2(carried_item_data.grid_size.x * CELL_SIZE, carried_item_data.grid_size.y * CELL_SIZE)
			var item_center_offset = item_pixel_size / 2
			var potential_top_left_pixel = local_pos - item_center_offset
			var potential_grid_pos = pixel_to_grid(potential_top_left_pixel)
			var is_valid_placement = can_place_generated_item_at(carried_item_data, potential_grid_pos, carried_item_data.get("instance_id"))

			grid_highlight_rect.position = grid_to_pixel(potential_grid_pos)
			grid_highlight_rect.size = item_pixel_size
			grid_highlight_rect.color = VALID_HIGHLIGHT_COLOR if is_valid_placement else INVALID_HIGHLIGHT_COLOR
			grid_highlight_rect.visible = true
			handled_highlight = true

	if not handled_highlight and grid_highlight_rect:
		grid_highlight_rect.visible = false

func add_generated_item(item_instance_data: Dictionary) -> bool:
	if not item_instance_data or not item_instance_data.has("instance_id"): return false
	var instance_id = item_instance_data.instance_id
	for y in range(int(GRID_SIZE.y)):
		for x in range(int(GRID_SIZE.x)):
			var grid_pos = Vector2(x, y)
			if can_place_generated_item_at(item_instance_data, grid_pos):
				inventory_data[instance_id] = item_instance_data.duplicate(true)
				inventory_data[instance_id]["grid_position"] = grid_pos
				print("creating item")
				var item_instance = create_item_instance(instance_id, item_instance_data)
				inventory_grid_node.add_child(item_instance)
				item_instance.position = grid_to_pixel(grid_pos)
				GlobalInventory.inventory_updated(inventory_data)
				return true
	print("Inventory: No room found for item '%s'." % instance_id)
	return false

func create_item_instance(instance_id: String, item_instance_data: Dictionary) -> Control:
	var item_instance = ColorRect.new()
	item_instance.name = instance_id
	item_instance.mouse_filter = Control.MOUSE_FILTER_STOP
	var item_grid_size = item_instance_data.get("grid_size", Vector2(1, 1))
	item_instance.custom_minimum_size = Vector2(item_grid_size.x * CELL_SIZE, item_grid_size.y * CELL_SIZE)
	item_instance.size = item_instance.custom_minimum_size
	var tooltip_updated_color = item_instance_data.get("tooltip_color", Color.GRAY)
	if type_string(typeof(tooltip_updated_color)) == 'String':
		var modified_string = tooltip_updated_color.replace("(", "Color(").strip_edges()
		tooltip_updated_color = str_to_var(modified_string)
	item_instance.color = tooltip_updated_color
	var label = Label.new()
	label.text = item_instance_data.get("display_name", "N/A")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.BLACK)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	item_instance.add_child(label)
	item_instance.connect("gui_input", Callable(self, "_on_item_gui_input").bind(item_instance, instance_id))
	item_instance.connect("mouse_entered", Callable(self, "_on_item_mouse_entered").bind(item_instance_data))
	item_instance.connect("mouse_exited", Callable(self, "_on_item_mouse_exited"))
	return item_instance

func can_place_generated_item_at(item_data_to_place: Dictionary, grid_position: Vector2, ignore_instance_id: String = "") -> bool:
	if not item_data_to_place or not item_data_to_place.has("grid_size"): 
		return false
	
	var item_size_data = item_data_to_place["grid_size"]
	var item_size_vector: Vector2 = Vector2(1, 1)
	
	if item_size_data is Vector2: item_size_vector = item_size_data
	elif item_size_data is Array and item_size_data.size() == 2:
		if (typeof(item_size_data[0]) == TYPE_INT or typeof(item_size_data[0]) == TYPE_FLOAT) and \
		   (typeof(item_size_data[1]) == TYPE_INT or typeof(item_size_data[1]) == TYPE_FLOAT):
			item_size_vector = Vector2(float(item_size_data[0]), float(item_size_data[1]))
	elif item_size_data is String:
		var cleaned_str = item_size_data.strip_edges()
		if cleaned_str.begins_with("(") and cleaned_str.ends_with(")"):
			cleaned_str = cleaned_str.trim_prefix("(").trim_suffix(")")
			var parts = cleaned_str.split(",", false, 1)
			if parts.size() == 2 and parts[0].strip_edges().is_valid_float() and parts[1].strip_edges().is_valid_float():
				item_size_vector = Vector2(float(parts[0].strip_edges()), float(parts[1].strip_edges()))
		else:
			var converted_var = str_to_var(item_size_data)
			if converted_var is Vector2: item_size_vector = converted_var
	elif item_size_data is Dictionary:
		if item_size_data.has("x") and item_size_data.has("y"):
			if (typeof(item_size_data.x) == TYPE_INT or typeof(item_size_data.x) == TYPE_FLOAT) and \
				(typeof(item_size_data.y) == TYPE_INT or typeof(item_size_data.y) == TYPE_FLOAT):
				item_size_vector = Vector2(float(item_size_data.x), float(item_size_data.y))
	
	var item_size_i = Vector2i(int(item_size_vector.x), int(item_size_vector.y))
	var grid_pos_i = Vector2i(int(grid_position.x), int(grid_position.y))
	
	if not is_valid_grid_position(grid_pos_i, item_size_i): 
		return false
		
	var target_rect = Rect2i(grid_pos_i, item_size_i)
	
	for other_instance_id in inventory_data:
		if other_instance_id == ignore_instance_id: continue
		var item_id_being_placed = item_data_to_place.get("instance_id")
		if item_id_being_placed and other_instance_id == item_id_being_placed: continue

		var other_data = inventory_data[other_instance_id]
		if not other_data or not other_data.has("grid_position") or not other_data.has("grid_size"): continue
		
		var other_pos_data = other_data["grid_position"]
		var other_pos_vector: Vector2 = Vector2.ZERO

		if other_pos_data is Vector2:
			other_pos_vector = other_pos_data
		elif other_pos_data is Array and other_pos_data.size() == 2:
			if (typeof(other_pos_data[0]) == TYPE_INT or typeof(other_pos_data[0]) == TYPE_FLOAT) and \
			   (typeof(other_pos_data[1]) == TYPE_INT or typeof(other_pos_data[1]) == TYPE_FLOAT):
				other_pos_vector = Vector2(float(other_pos_data[0]), float(other_pos_data[1]))
		elif other_pos_data is String:
			var _cleaned_str = other_pos_data.strip_edges()
			if _cleaned_str.begins_with("(") and _cleaned_str.ends_with(")"):
				_cleaned_str = _cleaned_str.trim_prefix("(").trim_suffix(")")
				var _parts = _cleaned_str.split(",", false, 1)
				if _parts.size() == 2 and _parts[0].strip_edges().is_valid_float() and _parts[1].strip_edges().is_valid_float():
					other_pos_vector = Vector2(float(_parts[0].strip_edges()), float(_parts[1].strip_edges()))
			else:
				var _converted_var = str_to_var(other_pos_data)
				if _converted_var is Vector2:
					other_pos_vector = _converted_var
		elif other_pos_data is Dictionary:
			if other_pos_data.has("x") and other_pos_data.has("y"):
				if (typeof(other_pos_data.x) == TYPE_INT or typeof(other_pos_data.x) == TYPE_FLOAT) and \
					(typeof(other_pos_data.y) == TYPE_INT or typeof(other_pos_data.y) == TYPE_FLOAT):
					other_pos_vector = Vector2(float(other_pos_data.x), float(other_pos_data.y))

		var other_size_data = other_data["grid_size"]
		var other_size_vector : Vector2 = Vector2(1,1)
		if other_size_data is Vector2: other_size_vector = other_size_data
		elif other_size_data is Array and other_size_data.size() == 2:
			if (typeof(other_size_data[0]) == TYPE_INT or typeof(other_size_data[0]) == TYPE_FLOAT) and \
			   (typeof(other_size_data[1]) == TYPE_INT or typeof(other_size_data[1]) == TYPE_FLOAT):
				other_size_vector = Vector2(float(other_size_data[0]), float(other_size_data[1]))
		elif other_size_data is String:
			var __cleaned_str = other_size_data.strip_edges()
			if __cleaned_str.begins_with("(") and __cleaned_str.ends_with(")"):
				__cleaned_str = __cleaned_str.trim_prefix("(").trim_suffix(")")
				var __parts = __cleaned_str.split(",", false, 1)
				if __parts.size() == 2 and __parts[0].strip_edges().is_valid_float() and __parts[1].strip_edges().is_valid_float():
					other_size_vector = Vector2(float(__parts[0].strip_edges()), float(__parts[1].strip_edges()))
			else:
				var __converted_var = str_to_var(other_size_data)
				if __converted_var is Vector2: other_size_vector = __converted_var
		elif other_size_data is Dictionary:
			if other_size_data.has("x") and other_size_data.has("y"):
				if (typeof(other_size_data.x) == TYPE_INT or typeof(other_size_data.x) == TYPE_FLOAT) and \
					(typeof(other_size_data.y) == TYPE_INT or typeof(other_size_data.y) == TYPE_FLOAT):
					other_size_vector = Vector2(float(other_size_data.x), float(other_size_data.y))

		var other_pos_i = Vector2i(int(other_pos_vector.x), int(other_pos_vector.y))
		var other_size_i = Vector2i(int(other_size_vector.x), int(other_size_vector.y))

		var other_rect = Rect2i(other_pos_i, other_size_i)

		if target_rect.intersects(other_rect): return false
	return true

func remove_item(instance_id: String):
	if not inventory_data.has(instance_id) and not equipped_items.values().has(instance_id): return false
	var item_node = inventory_grid_node.get_node_or_null(instance_id)
	if is_instance_valid(item_node): item_node.queue_free()
	else:
		for slot_id in equipped_items:
			if equipped_items[slot_id] == instance_id:
				var slot_node = get_node_or_null(slot_paths.get(slot_id))
				if is_instance_valid(slot_node):
					item_node = slot_node.get_node_or_null(instance_id)
					if is_instance_valid(item_node): item_node.queue_free()
				equipped_items.erase(slot_id)
				break
	if inventory_data.has(instance_id): inventory_data.erase(instance_id)
	GlobalInventory.inventory_updated(inventory_data)
	return true

func has_item(instance_id: String):
	return inventory_data.has(instance_id) or equipped_items.values().has(instance_id)

func grid_to_pixel(grid_pos: Vector2):
	return Vector2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE)

func pixel_to_grid(pixel_pos: Vector2):
	return Vector2(floor(pixel_pos.x / CELL_SIZE), floor(pixel_pos.y / CELL_SIZE))

func _on_item_gui_input(event: InputEvent, item_instance: Control, instance_id: String):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_carrying_item:
			print("Item Input: Handling pickup for item: ", instance_id)
			_pickup_item_from_grid(item_instance, instance_id)
			get_viewport().set_input_as_handled()

func _on_equipment_slot_input(event: InputEvent, slot_node: Panel, slot_id: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_carrying_item and equipped_items.has(slot_id):
			print("Slot Input: Handling pickup from slot: ", slot_id)
			_pickup_item_from_slot(slot_node, slot_id)
			get_viewport().set_input_as_handled()
			
func _pickup_item_from_grid(item_instance: Control, instance_id: String):
	if not inventory_data.has(instance_id): return
	var item_data_local = inventory_data[instance_id]

	is_carrying_item = true
	carried_item = item_instance
	carried_item_data = item_data_local.duplicate(true)
	carry_origin_type = "grid"
	carry_origin_info = item_data_local.grid_position

	inventory_data.erase(instance_id)

	item_instance.reparent(self)
	carried_item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_highlights()
	_hide_tooltip()
	GlobalInventory.inventory_updated(inventory_data)

func _pickup_item_from_slot(slot_node: Panel, slot_id: int):
	if not equipped_items.has(slot_id): return
	var instance_id = equipped_items[slot_id]
	var item_instance = slot_node.get_node_or_null(instance_id)
	if not is_instance_valid(item_instance): return
	var item_data_local = get_item_data_from_anywhere(instance_id)
	if not item_data_local: return

	is_carrying_item = true
	carried_item = item_instance
	carried_item_data = item_data_local.duplicate(true)
	carry_origin_type = "slot"
	carry_origin_info = slot_id

	equipped_items.erase(slot_id)
	equipped_item_data.erase(slot_id)

	item_instance.reparent(self)
	carried_item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_highlights()
	_hide_tooltip()
	GlobalInventory.inventory_updated(inventory_data)
	GlobalInventory.equipment_updated(slot_id, {})

func _handle_placement_click():
	if not is_carrying_item: return

	var placed_successfully = _try_place_carried_item()

	if placed_successfully:
		_clear_carry_state()

func _try_place_carried_item() -> bool:
	print("Try Place Carried Item: Checking slots and grid...")
	var mouse_pos = get_global_mouse_position()
	var result = false

	for slot_id in slot_paths:
		var slot_node = get_node_or_null(slot_paths[slot_id])
		if slot_node and slot_node.get_global_rect().has_point(mouse_pos):
			print("Try Place Carried Item: Mouse over slot ", slot_id)
			result = _try_place_in_slot(slot_id)
			print("Try Place Carried Item: _try_place_in_slot returned: ", result)
			return result

	var grid_node = inventory_grid_node
	if is_instance_valid(grid_node):
		var grid_rect = grid_node.get_global_rect()
		var is_over_grid = grid_rect.has_point(mouse_pos)
		print("Try Place Carried Item: Checking Grid. Rect=", grid_rect, " GlobalMousePos=", mouse_pos, " OverGrid=", is_over_grid)
		if is_over_grid:
			print("Try Place Carried Item: Mouse detected over grid. Calling _try_place_in_grid...")
			result = _try_place_in_grid()
			print("Try Place Carried Item: _try_place_in_grid returned: ", result)
			return result

	return false

func _try_place_in_slot(target_slot_id: int) -> bool:
	print("Try Place In Slot: Target Slot ID: ", target_slot_id)
	var slot_node = get_node_or_null(slot_paths[target_slot_id])
	if not is_instance_valid(slot_node):
		print("Try Place In Slot: Slot node invalid.")
		return false

	var can_equip_here = self._can_equip_to_slot(carried_item_data, target_slot_id, true)
	print("Try Place In Slot: Can carried item type go in target slot %d? %s" % [target_slot_id, can_equip_here])

	if not equipped_items.has(target_slot_id):
		if can_equip_here: 
			print("Try Place In Slot: Slot is empty and type is valid. Equipping item ", carried_item_data.instance_id)
			var instance_id = carried_item_data.instance_id
			var data_to_equip = carried_item_data.duplicate(true)
			equipped_items[target_slot_id] = instance_id
			equipped_item_data[target_slot_id] = data_to_equip

			carried_item.reparent(slot_node)
			_update_instance_visuals_for_slot(carried_item, slot_node)

			GlobalInventory.inventory_updated(inventory_data)
			GlobalInventory.equipment_updated(target_slot_id, data_to_equip)
			print("Try Place In Slot: Equip successful, returning true.")
			return true
		else:
			print("Try Place In Slot: Slot is empty but carried item type is invalid, returning false.")
			return false

	var current_item_in_slot_id = equipped_items.get(target_slot_id)
	if current_item_in_slot_id: 
		print("Try Place In Slot: Slot occupied by ", current_item_in_slot_id, ". Attempting swap...")
		var current_item_in_slot_data = get_item_data_from_anywhere(current_item_in_slot_id)
		if not current_item_in_slot_data:
			print("Try Place In Slot: Swap failed - missing data for item in slot.")
			return false

		var carried_can_go_target : bool = can_equip_here
		var slot_can_go_origin : bool = false

		print("  SWAP_CHECK: Carried item ('%s') valid for target slot %d? %s" % [carried_item_data.instance_id, target_slot_id, carried_can_go_target])

		if carry_origin_type == "grid":
			print("  SWAP_CHECK: Checking if slot item ('%s') can go to grid origin: %s" % [current_item_in_slot_id, carry_origin_info])
			slot_can_go_origin = self.can_place_generated_item_at(current_item_in_slot_data, carry_origin_info)
			print("  SWAP_CHECK: Result (can place on grid): ", slot_can_go_origin)
		elif carry_origin_type == "slot":
			print("  SWAP_CHECK: Checking if slot item ('%s') can go to slot origin: %s" % [current_item_in_slot_id, carry_origin_info])
			slot_can_go_origin = self._can_equip_to_slot(current_item_in_slot_data, carry_origin_info, true)
			print("  SWAP_CHECK: Result (can equip to origin slot): ", slot_can_go_origin)

		if carried_can_go_target and slot_can_go_origin:
			print("Try Place In Slot: Initiating carry for item '%s' after swap." % current_item_in_slot_id)
			var instance_to_pickup : Control = null
			var pickup_success = false

			if carry_origin_type == "grid": 
				_pickup_item_from_grid(instance_to_pickup, current_item_in_slot_id)
				self._swap_grid_item_with_slot(
					carried_item_data.instance_id, carried_item, carried_item_data,
					target_slot_id,
					current_item_in_slot_id, current_item_in_slot_data 
				)
				pickup_success = true
			elif carry_origin_type == "slot":
				var origin_slot_node = get_node_or_null(slot_paths[carry_origin_info])
				_pickup_item_from_slot(origin_slot_node, carry_origin_info)
				self._swap_slot_item_with_slot(
					carried_item_data.instance_id, carried_item, carried_item_data,
					carry_origin_info, target_slot_id,
					current_item_in_slot_id, current_item_in_slot_data
				)
				pickup_success = true
			if pickup_success:
				carry_origin_type = "slot"
				carry_origin_info = target_slot_id
				print("Try Place In Slot: Carry state updated. Now carrying '%s', origin was slot %d" % [carried_item_data.instance_id, carry_origin_info])
			else:
				printerr("Swap Pickup Glitch: Failed to pickup swapped item '%s'. Canceling carry." % current_item_in_slot_id)
				_cancel_carry()

			print("Try Place In Slot: Swap resulted in new carry, returning false.")
			return true
		else:
			print("Try Place In Slot: Swap check FAILED (one or both items cannot go to target location), returning false.")
			return false

	print("Try Place In Slot: Cannot place (invalid type?) or swap, returning false.")
	return false

func _try_place_in_grid() -> bool:
	var mouse_pos = get_global_mouse_position()
	var grid_global_rect = inventory_grid_node.get_global_rect()
	var local_pos = mouse_pos - grid_global_rect.position
	var item_pixel_size = Vector2(carried_item_data.grid_size.x * CELL_SIZE, carried_item_data.grid_size.y * CELL_SIZE)
	var item_center_offset = item_pixel_size / 2
	var potential_top_left_pixel = local_pos - item_center_offset
	var potential_grid_pos = pixel_to_grid(potential_top_left_pixel)

	if can_place_generated_item_at(carried_item_data, potential_grid_pos, carried_item_data.instance_id):
		inventory_data[carried_item_data.instance_id] = carried_item_data
		inventory_data[carried_item_data.instance_id]["grid_position"] = potential_grid_pos

		carried_item.reparent(inventory_grid_node)
		carried_item.position = grid_to_pixel(potential_grid_pos)
		_update_instance_visuals_for_grid(carried_item, carried_item_data)

		GlobalInventory.inventory_updated(inventory_data)
		return true

	return false

func _cancel_carry():
	if not is_carrying_item: return

	print("Canceling carry...")
	var success = false
	var item_data_returned = carried_item_data.duplicate(true)
	if carry_origin_type == "grid":
		if can_place_generated_item_at(carried_item_data, carry_origin_info, carried_item_data.instance_id):
			inventory_data[carried_item_data.instance_id] = carried_item_data
			inventory_data[carried_item_data.instance_id]["grid_position"] = carry_origin_info
			carried_item.reparent(inventory_grid_node)
			carried_item.position = grid_to_pixel(carry_origin_info)
			_update_instance_visuals_for_grid(carried_item, carried_item_data)
			success = true
		else:
			success = add_generated_item(carried_item_data)
			if success: carried_item.queue_free()

	elif carry_origin_type == "slot":
		var slot_node = get_node_or_null(slot_paths[carry_origin_info])
		if _can_equip_to_slot(carried_item_data, carry_origin_info, true) and is_instance_valid(slot_node):
			equipped_items[carry_origin_info] = carried_item_data.instance_id
			equipped_item_data[carry_origin_info] = item_data_returned
			carried_item.reparent(slot_node)
			_update_instance_visuals_for_slot(carried_item, slot_node)
			GlobalInventory.equipment_updated(carry_origin_info, item_data_returned)
			success = true
		else:
			success = add_generated_item(carried_item_data)
			if success: carried_item.queue_free()

	if not success:
		printerr("Failed to place carried item back on cancel! Item lost: ", carried_item_data.instance_id)
		carried_item.queue_free()

	_clear_carry_state()
	GlobalInventory.inventory_updated(inventory_data)

func _clear_carry_state():
	is_carrying_item = false
	carried_item = null
	carried_item_data = {}
	carry_origin_type = ""
	carry_origin_info = null
	_reset_highlights()

func _pickup_item_from_inventory(item_instance: Control, instance_id: String):
	if not inventory_data.has(instance_id): return
	var item_data_local = inventory_data[instance_id]

	is_carrying_item = true
	carried_item = item_instance
	carried_item_data = item_data_local.duplicate(true)
	carry_origin_type = "grid"
	carry_origin_info = item_data_local.grid_position

	inventory_data.erase(instance_id)

	item_instance.reparent(self)
	_update_highlights()
	_hide_tooltip()

func _can_place_carried_item_in_slot(target_slot_id: int) -> bool:
	if not is_carrying_item: return false
	if not _can_equip_to_slot(carried_item_data, target_slot_id, true):
		return false
	var current_item_in_slot_id = equipped_items.get(target_slot_id)
	if not current_item_in_slot_id: return true 

	var current_item_in_slot_data = get_item_data_from_anywhere(current_item_in_slot_id)
	if not current_item_in_slot_data: return false
	if carry_origin_type == "grid":
		return can_place_generated_item_at(current_item_in_slot_data, carry_origin_info)
	elif carry_origin_type == "slot":
		return _can_equip_to_slot(current_item_in_slot_data, carry_origin_info, true)

	return false

func _update_instance_visuals_for_grid(item_instance: Control, item_data: Dictionary):
	var item_grid_size = item_data.get("grid_size", Vector2(1, 1))
	item_instance.custom_minimum_size = Vector2(item_grid_size.x * CELL_SIZE, item_grid_size.y * CELL_SIZE)
	item_instance.size = item_instance.custom_minimum_size
	item_instance.mouse_filter = Control.MOUSE_FILTER_STOP

	var instance_id = item_instance.name
	var connected_callable = Callable(self, "_on_item_gui_input").bind(item_instance, instance_id)
	if not item_instance.is_connected("gui_input", connected_callable):
		item_instance.connect("gui_input", connected_callable)
		print("Reconnected gui_input for grid item: ", instance_id)

func _update_instance_visuals_for_slot(item_instance: Control, slot_node: Panel):
	item_instance.position = Vector2.ZERO
	item_instance.size = slot_node.size
	item_instance.mouse_filter = Control.MOUSE_FILTER_PASS

	var instance_id = item_instance.name
	var connected_callable = Callable(self, "_on_item_gui_input").bind(item_instance, instance_id)
	if item_instance.is_connected("gui_input", connected_callable):
		item_instance.disconnect("gui_input", connected_callable)
		print("Disconnected gui_input for equipped item: ", instance_id)

func get_item_data_from_anywhere(instance_id: String) -> Dictionary:
	if is_carrying_item and carried_item_data and carried_item_data.instance_id == instance_id:
		return carried_item_data

	if inventory_data.has(instance_id):
		return inventory_data[instance_id]

	for slot_id in equipped_items:
		if equipped_items[slot_id] == instance_id:
			if equipped_item_data.has(slot_id):
				return equipped_item_data[slot_id]
			else:
				printerr("Data inconsistency: Found equipped ID '%s' in slot %d, but no data in equipped_item_data." % [instance_id, slot_id])
				return {}

	printerr("get_item_data_from_anywhere: Could not find data for instance_id: ", instance_id)
	return {}

func _on_item_mouse_entered(item_data):
	if is_carrying_item: return
	if tooltip_instance and item_data:
		tooltip_instance.update_content(item_data)
		tooltip_instance.visible = true

func _on_item_mouse_exited():
	if tooltip_instance: tooltip_instance.visible = false

func _hide_tooltip():
	if tooltip_instance: tooltip_instance.visible = false

func _reset_highlights():
	if grid_highlight_rect: grid_highlight_rect.visible = false
	for slot_id in slot_paths:
		var slot_node = get_node_or_null(slot_paths[slot_id])
		if slot_node: slot_node.modulate = Color(1, 1, 1, 1)

func get_save_data() -> Dictionary:
	var grid_data = {}
	for instance_id in inventory_data:
		grid_data[instance_id] = inventory_data[instance_id].duplicate(true)

	var equipped_data = {}
	for slot_id in equipped_item_data:
		equipped_data[str(slot_id)] = equipped_item_data[slot_id].duplicate(true)

	return {"grid": grid_data, "equipped": equipped_data }

func load_inventory_state(data: Dictionary):
	clear_all_items()

	var grid_items_to_load = data.get("grid", {})
	for instance_id in grid_items_to_load:
		var full_item_data = grid_items_to_load[instance_id]
		if full_item_data is Dictionary and full_item_data.has("grid_position"):
			var grid_pos_data = full_item_data["grid_position"]
			var grid_pos_vector: Vector2 = Vector2.ZERO
			
			if grid_pos_data is Vector2:
				grid_pos_vector = grid_pos_data
			elif grid_pos_data is Array and grid_pos_data.size() == 2:
				if (typeof(grid_pos_data[0]) == TYPE_INT or typeof(grid_pos_data[0]) == TYPE_FLOAT) and \
				   (typeof(grid_pos_data[1]) == TYPE_INT or typeof(grid_pos_data[1]) == TYPE_FLOAT):
					grid_pos_vector = Vector2(float(grid_pos_data[0]), float(grid_pos_data[1]))
				else:
					printerr("Load Error: Invalid non-numeric elements in grid_position array '", grid_pos_data, "' for item ", instance_id, ". Using default Vector2.ZERO.")
			elif grid_pos_data is String:
				var cleaned_str = grid_pos_data.strip_edges()
				if cleaned_str.begins_with("(") and cleaned_str.ends_with(")"):
					cleaned_str = cleaned_str.trim_prefix("(").trim_suffix(")")
					var parts = cleaned_str.split(",", false, 1)
					if parts.size() == 2 and parts[0].strip_edges().is_valid_float() and parts[1].strip_edges().is_valid_float():
						grid_pos_vector = Vector2(float(parts[0].strip_edges()), float(parts[1].strip_edges()))
					else:
						printerr("Load Error: Could not parse grid_position string '", grid_pos_data, "' for item ", instance_id, ". Using default Vector2.ZERO.")
				else:
					var converted_var = str_to_var(grid_pos_data)
					if converted_var is Vector2:
						grid_pos_vector = converted_var
					else:
						printerr("Load Error: Unrecognized or invalid grid_position string format '", grid_pos_data, "' for item ", instance_id, ". Using default Vector2.ZERO.")
			else:
				printerr("Load Error: Unexpected data type '", typeof(grid_pos_data), "' for grid_position for item ", instance_id, ". Using default Vector2.ZERO.")
			if not _load_item_to_grid(instance_id, full_item_data, grid_pos_vector):
				printerr("Failed to load grid item: ", instance_id, " at ", grid_pos_vector)
		else: 
			printerr("Invalid grid item data for instance: ", instance_id)

	var equipped_items_to_load = data.get("equipped", {})
	for slot_id_str in equipped_items_to_load:
		var full_item_data = equipped_items_to_load[slot_id_str]
		var slot_id = int(slot_id_str)
		if full_item_data is Dictionary and full_item_data.has("instance_id"):
			var instance_id = full_item_data.instance_id
			if not _load_item_to_slot(instance_id, full_item_data, slot_id):
				printerr("Failed to load equipped item: ", instance_id, " to slot ", slot_id)
		else: 
			printerr("Invalid equipped item data for slot: ", slot_id_str)

	GlobalInventory.inventory_updated(inventory_data)

func clear_all_items():
	var inv_keys = inventory_data.keys()
	for instance_id in inv_keys:
		var item_node = inventory_grid_node.get_node_or_null(instance_id)
		if is_instance_valid(item_node): item_node.queue_free()
	inventory_data.clear()

	var equipped_copy = equipped_items.duplicate()
	for slot_id in equipped_copy:
		var instance_id = equipped_copy[slot_id]
		var slot_node = get_node_or_null(slot_paths.get(slot_id))
		if is_instance_valid(slot_node):
			var item_node = slot_node.get_node_or_null(instance_id)
			if is_instance_valid(item_node): item_node.queue_free()
		GlobalInventory.equipment_updated(slot_id, {})
	equipped_items.clear()
	equipped_item_data.clear()

	_reset_highlights()
	if is_carrying_item: _cancel_carry()

func _load_item_to_grid(instance_id: String, item_data: Dictionary, grid_position: Vector2) -> bool:
	if not item_data: 
		return false
		
	var item_size_data = item_data.get("grid_size", Vector2(1,1))
	var item_size_vector: Vector2 = Vector2(1, 1)

	if item_size_data is Vector2:
		item_size_vector = item_size_data
	elif item_size_data is Array and item_size_data.size() == 2:
		if (typeof(item_size_data[0]) == TYPE_INT or typeof(item_size_data[0]) == TYPE_FLOAT) and \
		   (typeof(item_size_data[1]) == TYPE_INT or typeof(item_size_data[1]) == TYPE_FLOAT):
			item_size_vector = Vector2(float(item_size_data[0]), float(item_size_data[1]))
		else:
			printerr("Load Error: Invalid non-numeric elements in grid_size array '", item_size_data, "' for item ", instance_id, ". Using default Vector2(1,1).")
	elif item_size_data is String:
		var cleaned_str = item_size_data.strip_edges()
		if cleaned_str.begins_with("(") and cleaned_str.ends_with(")"):
			cleaned_str = cleaned_str.trim_prefix("(").trim_suffix(")")
			var parts = cleaned_str.split(",", false, 1)
			if parts.size() == 2 and parts[0].strip_edges().is_valid_float() and parts[1].strip_edges().is_valid_float():
				item_size_vector = Vector2(float(parts[0].strip_edges()), float(parts[1].strip_edges()))
			else:
				printerr("Load Error: Could not parse grid_size string '", item_size_data, "' for item ", instance_id, ". Using default Vector2(1,1).")
		else:
			var converted_var = str_to_var(item_size_data)
			if converted_var is Vector2:
				item_size_vector = converted_var
			else:
				printerr("Load Error: Unrecognized or invalid grid_size string format '", item_size_data, "' for item ", instance_id, ". Using default Vector2(1,1).")
	elif item_size_data is Dictionary: 
		if item_size_data.has("x") and item_size_data.has("y"):
			if (typeof(item_size_data.x) == TYPE_INT or typeof(item_size_data.x) == TYPE_FLOAT) and \
				(typeof(item_size_data.y) == TYPE_INT or typeof(item_size_data.y) == TYPE_FLOAT):
				item_size_vector = Vector2(float(item_size_data.x), float(item_size_data.y))
			else:
				printerr("Load Error: Invalid non-numeric x/y in grid_size dictionary '", item_size_data, "' for item ", instance_id, ". Using default Vector2(1,1).")
		else:
			printerr("Load Error: Incomplete grid_size dictionary '", item_size_data, "' for item ", instance_id, ". Using default Vector2(1,1).")
	else:
		printerr("Load Error: Unexpected data type '", typeof(item_size_data), "' for grid_size for item ", instance_id, ". Using default Vector2(1,1).")
	
	if not is_valid_grid_position(grid_position, item_size_vector):
		printerr("Load Error: Invalid grid position ", grid_position, " for item ", instance_id, " size ", item_size_vector)
		return false
	if not can_place_generated_item_at(item_data, grid_position): 
		printerr("Load Error: Cannot place item ", instance_id, " at ", grid_position, " due to overlap.")
		return false

	var data_copy = item_data.duplicate(true)
	data_copy["grid_position"] = grid_position
	data_copy["grid_size"] = item_size_vector
	inventory_data[instance_id] = data_copy

	var item_instance = create_item_instance(instance_id, data_copy)
	inventory_grid_node.add_child(item_instance)
	item_instance.position = grid_to_pixel(grid_position)

	return true

func _load_item_to_slot(instance_id: String, item_data: Dictionary, slot_id: int) -> bool:
	if not item_data: return false
	if not slot_paths.has(slot_id): return false
	if equipped_items.has(slot_id): return false

	var slot_node = get_node_or_null(slot_paths[slot_id])
	if not is_instance_valid(slot_node): return false
	if not item_data.get("valid_slots", []).has(slot_id): return false

	var data_to_load = item_data.duplicate(true)
	equipped_items[slot_id] = instance_id
	equipped_item_data[slot_id] = data_to_load

	var item_instance = create_item_instance(instance_id, item_data)
	slot_node.add_child(item_instance)
	_update_instance_visuals_for_slot(item_instance, slot_node)
	GlobalInventory.equipment_updated(slot_id, data_to_load)
	return true

func is_valid_grid_position(grid_pos: Vector2, item_size: Vector2) -> bool:
	if grid_pos.x < 0 or grid_pos.y < 0: return false
	if grid_pos.x + item_size.x > GRID_SIZE.x: return false
	if grid_pos.y + item_size.y > GRID_SIZE.y: return false
	return true

func _can_equip_to_slot(item_data: Dictionary, slot_id: int, ignore_occupied: bool = false) -> bool:
	if not item_data or not slot_paths.has(slot_id): return false
	var valid_slots = item_data.get("valid_slots", [])
	if not valid_slots.has(slot_id): return false
	if not ignore_occupied and equipped_items.has(slot_id): return false
	return true
	
func _swap_grid_item_with_slot(
	grid_instance_id: String, grid_item_instance: Control, grid_item_data: Dictionary,
	target_slot_id: int,
	slot_instance_id: String, slot_item_data: Dictionary
	) -> bool:

	var slot_node = get_node_or_null(slot_paths[target_slot_id])
	if not is_instance_valid(slot_node): return false
	var slot_item_instance = slot_node.get_node_or_null(slot_instance_id)
	if not is_instance_valid(slot_item_instance): return false

	if not grid_item_data or not slot_item_data:
		printerr("Swap Error: Missing data provided to _swap_grid_item_with_slot.")
		return false

	if not can_place_generated_item_at(slot_item_data, carry_origin_info):
		print("Cannot swap: Equipped item '%s' cannot fit in original grid position %s." % [slot_instance_id, carry_origin_info])
		return false
		
	var grid_data_copy = grid_item_data.duplicate(true)

	equipped_items.erase(target_slot_id)
	if equipped_item_data.has(target_slot_id): equipped_item_data.erase(target_slot_id)

	inventory_data[slot_instance_id] = slot_item_data
	inventory_data[slot_instance_id]["grid_position"] = carry_origin_info 
	equipped_items[target_slot_id] = grid_instance_id 
	equipped_item_data[target_slot_id] = grid_data_copy

	slot_node.remove_child(slot_item_instance)
	inventory_grid_node.add_child(slot_item_instance)
	slot_item_instance.position = grid_to_pixel(carry_origin_info)
	_update_instance_visuals_for_grid(slot_item_instance, slot_item_data)

	grid_item_instance.reparent(slot_node)
	_update_instance_visuals_for_slot(grid_item_instance, slot_node)

	GlobalInventory.inventory_updated(inventory_data)
	GlobalInventory.equipment_updated(target_slot_id, grid_data_copy)
	print("Swap grid<->slot successful.")
	return true

func _swap_slot_item_with_slot(
	origin_instance_id: String, origin_item_instance: Control, origin_item_data: Dictionary,
	origin_slot_id: int, target_slot_id: int,
	target_instance_id: String, target_item_data: Dictionary
	) -> bool:

	var origin_slot_node = get_node_or_null(slot_paths[origin_slot_id])
	var target_slot_node = get_node_or_null(slot_paths[target_slot_id])
	if not is_instance_valid(origin_slot_node) or not is_instance_valid(target_slot_node): return false
	var target_item_instance = target_slot_node.get_node_or_null(target_instance_id)
	if not is_instance_valid(target_item_instance): return false

	if not origin_item_data or not target_item_data:
		printerr("Swap Error: Missing data provided to _swap_slot_item_with_slot.")
		return false
	
	var origin_data_copy = origin_item_data.duplicate(true)
	var target_data_copy = target_item_data.duplicate(true)

	equipped_items[origin_slot_id] = target_instance_id
	equipped_items[target_slot_id] = origin_instance_id
	equipped_item_data[origin_slot_id] = target_data_copy
	equipped_item_data[target_slot_id] = origin_data_copy

	target_slot_node.remove_child(target_item_instance)
	origin_slot_node.add_child(target_item_instance)
	_update_instance_visuals_for_slot(target_item_instance, origin_slot_node)

	origin_item_instance.reparent(target_slot_node)
	_update_instance_visuals_for_slot(origin_item_instance, target_slot_node)

	GlobalInventory.inventory_updated(inventory_data)
	GlobalInventory.equipment_updated(origin_slot_id, target_data_copy)
	GlobalInventory.equipment_updated(target_slot_id, origin_data_copy)
	print("Swap slot<->slot successful.")
	return true
