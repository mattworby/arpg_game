extends Control

var cell_size := 32
var grid_size := Vector2i(12, 6)

signal item_moved_in_grid(item_data, old_pos, new_pos)
signal item_added_to_grid(item_data, new_pos)
signal item_removed_from_grid(item_data, old_pos)

var occupied_cells: Dictionary = {}
var inventory_item_scene = preload("res://scenes/menus/inventory/inventory_item.tscn")
var highlight_rect: ColorRect

func _ready():
	custom_minimum_size = Vector2(grid_size.x * cell_size, grid_size.y * cell_size)
	size = custom_minimum_size

	highlight_rect = ColorRect.new()
	highlight_rect.mouse_filter = MOUSE_FILTER_IGNORE
	highlight_rect.visible = false
	add_child(highlight_rect)

func _draw():
	var line_color = Color(0.3, 0.3, 0.3, 0.8)
	var grid_width_pixels = grid_size.x * cell_size
	var grid_height_pixels = grid_size.y * cell_size

	for x in range(grid_size.x + 1):
		draw_line(Vector2(x * cell_size, 0), Vector2(x * cell_size, grid_height_pixels), line_color, 1.0)
	for y in range(grid_size.y + 1):
		draw_line(Vector2(0, y * cell_size), Vector2(grid_width_pixels, y * cell_size), line_color, 1.0)

func is_valid_grid_position(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < grid_size.x and \
		   grid_pos.y >= 0 and grid_pos.y < grid_size.y

func can_place_item(item_data: Dictionary, grid_pos: Vector2i, exclude_item = null) -> bool:
	if item_data.is_empty() or not item_data.has("size"):
		printerr("InventoryGrid: Invalid item_data for placement check.")
		return false

	var item_size: Vector2i = item_data.get("size", Vector2i(1, 1))

	for y_offset in range(item_size.y):
		for x_offset in range(item_size.x):
			var check_pos = grid_pos + Vector2i(x_offset, y_offset)
			if not is_valid_grid_position(check_pos):
				return false
			if occupied_cells.has(check_pos):
				var occupying_item = occupied_cells[check_pos]
				if occupying_item != exclude_item:
					return false
	return true

func add_item(item_data: Dictionary, grid_pos: Vector2i) -> Node:
	if not can_place_item(item_data, grid_pos):
		printerr("InventoryGrid: Cannot place item '", item_data.get("name", "N/A"), "' at ", grid_pos, ". Area blocked or invalid.")
		return null

	var item_instance = inventory_item_scene.instantiate()
	add_child(item_instance)
	item_instance.set_item(item_data, grid_pos, self) # Pass self as parent_grid

	var item_size: Vector2i = item_data.get("size", Vector2i(1, 1))
	for y_offset in range(item_size.y):
		for x_offset in range(item_size.x):
			occupied_cells[grid_pos + Vector2i(x_offset, y_offset)] = item_instance

	print("Added item '", item_data.get("name", "N/A"), "' at ", grid_pos)
	emit_signal("item_added_to_grid", item_data, grid_pos)
	return item_instance


func remove_item(item_node: Node):
	if not is_instance_valid(item_node) or not item_node is InventoryItem:
		printerr("InventoryGrid: Invalid node passed to remove_item.")
		return

	var item_instance: InventoryItem = item_node
	var item_data = item_instance.item_data
	var grid_pos = item_instance.grid_position
	var item_size: Vector2i = item_data.get("size", Vector2i(1, 1))

	var cells_cleared = 0
	for y_offset in range(item_size.y):
		for x_offset in range(item_size.x):
			var cell_to_clear = grid_pos + Vector2i(x_offset, y_offset)
			if occupied_cells.has(cell_to_clear) and occupied_cells[cell_to_clear] == item_instance:
				occupied_cells.erase(cell_to_clear)
				cells_cleared += 1

	if cells_cleared == 0 and item_instance.get_parent() == self:
		print("InventoryGrid: Item '", item_data.get("name", "N/A"), "' was not found in occupied_cells map during removal.")

	print("Removed item '", item_data.get("name", "N/A"), "' from ", grid_pos)
	emit_signal("item_removed_from_grid", item_data, grid_pos)

	item_instance.queue_free()

func move_item(item_node: Node, new_grid_pos: Vector2i) -> bool:
	if not is_instance_valid(item_node) or not item_node is InventoryItem:
		printerr("InventoryGrid: Invalid node passed to move_item.")
		return false

	var item_instance: InventoryItem = item_node
	var item_data = item_instance.item_data
	var old_grid_pos = item_instance.grid_position

	if old_grid_pos == new_grid_pos:
		return true

	if not can_place_item(item_data, new_grid_pos, item_instance):
		printerr("InventoryGrid: Cannot move item '", item_data.get("name", "N/A"), "' to ", new_grid_pos, ". Area blocked or invalid.")
		return false

	var item_size: Vector2i = item_data.get("size", Vector2i(1, 1))
	for y_offset in range(item_size.y):
		for x_offset in range(item_size.x):
			var cell_to_clear = old_grid_pos + Vector2i(x_offset, y_offset)
			if occupied_cells.has(cell_to_clear) and occupied_cells[cell_to_clear] == item_instance:
				occupied_cells.erase(cell_to_clear)

	for y_offset in range(item_size.y):
		for x_offset in range(item_size.x):
			occupied_cells[new_grid_pos + Vector2i(x_offset, y_offset)] = item_instance

	item_instance.grid_position = new_grid_pos
	item_instance.position = grid_to_pixel(new_grid_pos)
	item_instance.restore_visibility()

	print("Moved item '", item_data.get("name", "N/A"), "' from ", old_grid_pos, " to ", new_grid_pos)
	emit_signal("item_moved_in_grid", item_data, old_grid_pos, new_grid_pos)
	return true

func find_empty_space_for(item_data: Dictionary) -> Vector2i:
	if item_data.is_empty() or not item_data.has("size"):
		return Vector2i(-1, -1)

	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var check_pos = Vector2i(x, y)
			if can_place_item(item_data, check_pos):
				return check_pos
	return Vector2i(-1, -1)

func _can_drop_data(at_position, data) -> bool:
	if not data is Dictionary or not data.has("item_data"):
		return false

	var grid_pos = pixel_to_grid(at_position)
	var item_data = data["item_data"]
	var source_node = data.get("source_node", null)

	var can_place = can_place_item(item_data, grid_pos, source_node if data.get("origin") == "grid" else null)

	update_drop_highlight(grid_pos, item_data.get("size", Vector2i(1,1)), can_place)

	return can_place


func _drop_data(at_position, data):
	print("Drop detected at grid pixel pos: ", at_position)
	hide_drop_highlight()

	if not data is Dictionary or not data.has("item_data"):
		printerr("InventoryGrid: Invalid data dropped.")
		return

	var grid_pos = pixel_to_grid(at_position)
	var item_data = data["item_data"]
	var origin = data.get("origin", "unknown")
	var source_node = data.get("source_node", null)

	print("Attempting to drop item '", item_data.get("name", "N/A"), "' from '", origin, "' at grid pos ", grid_pos)

	if origin == "grid":
		if is_instance_valid(source_node) and source_node is InventoryItem:
			if not move_item(source_node, grid_pos):
				printerr("InventoryGrid: Move failed during drop.")
				source_node.restore_visibility()
		else:
			printerr("InventoryGrid: Invalid source_node for grid-to-grid move.")

	elif origin == "equipment":
		var placed_item = add_item(item_data, grid_pos)
		if placed_item:
			if is_instance_valid(source_node) and source_node.has_method("clear_item"):
				source_node.clear_item()
				print("Cleared source equipment slot: ", source_node.name)
			else:
				printerr("InventoryGrid: Could not clear source equipment slot node: ", source_node)
		else:
			printerr("InventoryGrid: Failed to add item from equipment slot to grid.")
	else:
		printerr("InventoryGrid: Unknown drag origin: ", origin)

func update_drop_highlight(grid_pos: Vector2i, item_size: Vector2i, can_place: bool):
	highlight_rect.position = grid_to_pixel(grid_pos)
	highlight_rect.size = Vector2(item_size.x * cell_size, item_size.y * cell_size)
	highlight_rect.color = Color(0.2, 1.0, 0.2, 0.4) if can_place else Color(1.0, 0.2, 0.2, 0.4)
	highlight_rect.visible = true

func hide_drop_highlight():
	highlight_rect.visible = false

func _notification(what):
	if what == NOTIFICATION_MOUSE_EXIT:
		hide_drop_highlight()
	if what == NOTIFICATION_DRAG_END:
		hide_drop_highlight()

func pixel_to_grid(pixel_pos: Vector2) -> Vector2i:
	var x = floori(pixel_pos.x / cell_size)
	var y = floori(pixel_pos.y / cell_size)
	x = clamp(x, 0, grid_size.x - 1)
	y = clamp(y, 0, grid_size.y - 1)
	return Vector2i(x, y)

func grid_to_pixel(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * cell_size, grid_pos.y * cell_size)

func get_items_data() -> Array[Dictionary]:
	var items_list: Array[Dictionary] = []
	var processed_items = {}
	for cell in occupied_cells:
		var item_node : InventoryItem = occupied_cells[cell]
		if is_instance_valid(item_node) and not processed_items.has(item_node):
			items_list.append({
				"item_id": item_node.item_data.get("id", item_node.item_data.get("name")), # Need a reliable ID
				"grid_position": item_node.grid_position,
			})
			processed_items[item_node] = true
	return items_list
