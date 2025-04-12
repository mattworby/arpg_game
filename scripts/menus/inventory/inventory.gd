extends Control

signal inventory_state_changed(inventory_grid_data, equipment_data)

@onready var inventory_grid: Control = $InventoryWindow/InventoryPanel/InventoryGrid
@onready var equipment_slots_container = $InventoryWindow/EquipmentPanel
@onready var inventory_window: Panel = $InventoryWindow

var equipment_slots: Dictionary = {}

func _ready():
	_collect_equipment_slots(equipment_slots_container)

	if inventory_grid and inventory_grid.has_signal("item_moved_in_grid"):
		inventory_grid.item_moved_in_grid.connect(_on_grid_inventory_changed)
	if inventory_grid and inventory_grid.has_signal("item_added_to_grid"):
		inventory_grid.item_added_to_grid.connect(_on_grid_inventory_changed)
	if inventory_grid and inventory_grid.has_signal("item_removed_from_grid"):
		inventory_grid.item_removed_from_grid.connect(_on_grid_inventory_changed)
	else:
		printerr("Inventory: Could not connect signals from InventoryGrid.")

	for slot_type in equipment_slots:
		var slot_node = equipment_slots[slot_type]
		if slot_node.has_signal("item_equipped"):
			slot_node.item_equipped.connect(_on_equipment_changed)
		if slot_node.has_signal("item_unequipped"):
			pass

	visible = false
	print("Inventory UI Ready.")

func _collect_equipment_slots(node):
	for child in node.get_children():
		if child is Panel and child.has_meta("is_equipment_slot"):
			var slot_script = child.get_script()
			if slot_script and slot_script.has_method("get_slot_type"):
				var slot_type = child.get_slot_type()
				if slot_type != "none":
					if equipment_slots.has(slot_type) and slot_type != "ring":
						printerr("Inventory: Duplicate equipment slot found for type: ", slot_type)
					if slot_type == "ring":
						if child.name.to_lower().contains("left"):
							equipment_slots["ring_left"] = child
							child.slot_type = "ring_left"
						elif child.name.to_lower().contains("right"):
							equipment_slots["ring_right"] = child
							child.slot_type = "ring_right"
						else:
							if not equipment_slots.has("ring_1"):
								equipment_slots["ring_1"] = child
								child.slot_type = "ring_1"
							elif not equipment_slots.has("ring_2"):
								equipment_slots["ring_2"] = child
								child.slot_type = "ring_2"
					else:
						equipment_slots[slot_type] = child
					print("Found Equipment Slot: ", child.name, " Type: ", child.slot_type)
		if child.get_child_count() > 0:
			_collect_equipment_slots(child)

func toggle_inventory():
	visible = !visible
	if visible:
		move_to_front()
		print("Inventory Opened")
	else:
		print("Inventory Closed")

func load_inventory_data(grid_items: Array, equipped_items: Dictionary):
	print("Loading inventory data...")
	clear_all_items()

	if inventory_grid and inventory_grid.has_method("add_item"):
		for item_entry in grid_items:
			if item_entry is Dictionary and item_entry.has("item_id") and item_entry.has("grid_position"):
				var item_data = InventoryDatabase.create_instance_of_item(item_entry["item_id"])
				if not item_data.is_empty():
					item_data["id"] = item_entry["item_id"]
					inventory_grid.add_item(item_data, item_entry["grid_position"])
				else:
					printerr("Inventory: Could not get data for item ID: ", item_entry["item_id"])
			else:
				printerr("Inventory: Invalid grid item entry format: ", item_entry)

	for slot_key in equipped_items:
		var item_id = equipped_items[slot_key]
		if equipment_slots.has(slot_key):
			var slot_node = equipment_slots[slot_key]
			var item_data = InventoryDatabase.create_instance_of_item(item_id)
			if not item_data.is_empty() and slot_node.has_method("set_item"):
				item_data["id"] = item_id
				slot_node.set_item(item_data)
				print("Equipped '", item_data.get("name"), "' to slot '", slot_key, "'")
			else:
				printerr("Inventory: Could not equip item ID '", item_id, "' to slot '", slot_key, "'")
		else:
			printerr("Inventory: Equipment slot key not found during load: ", slot_key)

	print("Inventory data loaded.")

func clear_all_items():
	if inventory_grid and inventory_grid.has_method("get_children"):
		for child in inventory_grid.get_children():
			if child is InventoryItem:
				inventory_grid.remove_item(child)

	# Clear equipment
	for slot_type in equipment_slots:
		var slot_node = equipment_slots[slot_type]
		if slot_node.has_method("clear_item"):
			slot_node.clear_item()

func unequip_item(equipment_slot_node):
	if not is_instance_valid(equipment_slot_node) or not equipment_slot_node.has_method("get_item_data"):
		printerr("Inventory: Invalid node passed to unequip_item.")
		return

	var item_data = equipment_slot_node.get_item_data()
	if item_data == null:
		print("Inventory: Slot was already empty.")
		return

	print("Trying to unequip item: ", item_data.get("name", "N/A"))

	if inventory_grid and inventory_grid.has_method("find_empty_space_for"):
		var target_pos = inventory_grid.find_empty_space_for(item_data)
		if target_pos != Vector2i(-1, -1):
			print("Found space in grid at: ", target_pos)
			var added_item = inventory_grid.add_item(item_data, target_pos)
			if added_item:
				equipment_slot_node.clear_item()
				print("Unequipped '", item_data.get("name"), "' to grid position ", target_pos)
			else:
				printerr("Inventory: Failed to add unequipped item to grid.")
		else:
			print("Inventory: No space in grid to unequip item '", item_data.get("name"), "'.")
	else:
		printerr("Inventory: InventoryGrid not found or missing methods for unequip.")

func _on_grid_inventory_changed(item_data = null, pos1 = null, pos2 = null):
	emit_inventory_state()

func _on_equipment_changed(item_data = null, slot_type = null):
	emit_inventory_state()

func emit_inventory_state():
	var grid_data = []
	if inventory_grid and inventory_grid.has_method("get_items_data"):
		grid_data = inventory_grid.get_items_data()

	var equipment_data = {}
	for slot_key in equipment_slots:
		var slot_node = equipment_slots[slot_key]
		if slot_node.has_method("get_item_data"):
			var item_data = slot_node.get_item_data()
			if item_data != null and item_data.has("id"):
				equipment_data[slot_key] = item_data["id"] # Store item ID

	emit_signal("inventory_state_changed", grid_data, equipment_data)
