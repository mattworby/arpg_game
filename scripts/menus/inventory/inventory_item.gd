class_name InventoryItem
extends Control

var item_data: Dictionary = {}
var grid_position: Vector2i = Vector2i.ZERO
var inventory_grid = null 

@onready var item_display_node = $ItemTexture

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	if is_instance_valid(item_display_node):
		item_display_node.set_anchors_preset(Control.PRESET_FULL_RECT)
		item_display_node.set_offsets_preset(Control.PRESET_FULL_RECT)

func set_item(data: Dictionary, grid_pos: Vector2i, parent_grid):
	print("--- set_item called ---")
	if data:
		print("Item Name: ", data.get("name", "N/A"))
		print("Incoming Data 'size': ", data.get("size", "MISSING"))
	else:
		print("ERROR: Incoming data is null!")
		queue_free()
		return

	item_data = data
	grid_position = grid_pos
	inventory_grid = parent_grid

	if item_data.is_empty():
		printerr("InventoryItem: Received empty item data after assignment.")
		queue_free()
		return

	if not is_instance_valid(inventory_grid):
		printerr("InventoryItem: Inventory Grid reference is invalid!")
		queue_free()
		return

	var cell_pixel_size = inventory_grid.cell_size
	print("Grid Cell Size: ", cell_pixel_size)

	var item_size_cells : Vector2i = item_data.get("size", Vector2i(1, 1))
	print("Item Size (Cells): ", item_size_cells)

	var calculated_size = Vector2(item_size_cells.x * cell_pixel_size, item_size_cells.y * cell_pixel_size)
	print("Calculated Pixel Size: ", calculated_size)

	custom_minimum_size = calculated_size
	size = calculated_size

	print("Size AFTER setting: ", size)
	print("Custom Min Size AFTER setting: ", custom_minimum_size)

	if item_display_node is TextureRect and item_data.has("texture_path"):
		var texture = load(item_data.get("texture_path"))
		if texture:
			item_display_node.texture = texture
		else:
			item_display_node.texture = null
	elif item_display_node is ColorRect and item_data.has("color"):
		item_display_node.color = item_data.get("color")

	position = inventory_grid.grid_to_pixel(grid_position)
	print("Set Position: ", position)

	tooltip_text = item_data.get("name", "Unknown Item") + "\n" + item_data.get("description", "")
	print("--- set_item finished ---")

func _get_drag_data(at_position):
	if item_data.is_empty():
		return null

	print("Starting drag for: ", item_data.get("name"))

	var drag_data = {
		"origin": "grid",
		"item_data": item_data,
		"source_node": self,
		"grid_position": grid_position
	}

	var preview = TextureRect.new()
	preview.texture = $ItemTexture.texture
	var item_size_cells = item_data.get("size", Vector2i(1, 1))
	var cell_pixel_size = inventory_grid.cell_size if inventory_grid else 32
	preview.custom_minimum_size = Vector2(item_size_cells.x * cell_pixel_size, item_size_cells.y * cell_pixel_size)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = $ItemTexture.stretch_mode
	set_drag_preview(preview)

	modulate = Color(1, 1, 1, 0.5)

	return drag_data

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Attempting drag start on: ", item_data.get("name"))
		var drag_data = _get_drag_data(event.position)
		drag_data = _get_drag_data(event.position)
		if drag_data:
			get_viewport().gui_set_drag_data(drag_data)
		else:
			printerr("Could not get drag data for item.")

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		modulate = Color(1, 1, 1, 1)


func restore_visibility():
	modulate = Color(1, 1, 1, 1)
