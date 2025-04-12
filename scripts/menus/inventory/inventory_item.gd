class_name InventoryItem
extends Control

var item_data: Dictionary = {}
var grid_position: Vector2i = Vector2i.ZERO

var inventory_grid = null 

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP

func set_item(data: Dictionary, grid_pos: Vector2i, parent_grid):
	item_data = data
	grid_position = grid_pos
	inventory_grid = parent_grid

	if item_data.is_empty():
		printerr("InventoryItem: Received empty item data.")
		queue_free()
		return

	var texture_path = item_data.get("texture_path", "")
	var item_size_cells = item_data.get("size", Vector2i(1, 1))

	if texture_path.is_empty():
		printerr("InventoryItem: Item data missing texture_path: ", item_data.get("name", "N/A"))
	else:
		var texture = load(texture_path)
		if texture:
			$ItemTexture.texture = texture
		else:
			printerr("InventoryItem: Failed to load texture: ", texture_path)

	var cell_pixel_size = inventory_grid.cell_size if inventory_grid else 32
	custom_minimum_size = Vector2(item_size_cells.x * cell_pixel_size, item_size_cells.y * cell_pixel_size)
	size = custom_minimum_size

	if inventory_grid:
		position = inventory_grid.grid_to_pixel(grid_position)

	tooltip_text = item_data.get("name", "Unknown Item") + "\n" + item_data.get("description", "")

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
