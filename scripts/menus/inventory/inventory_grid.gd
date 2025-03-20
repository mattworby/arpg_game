extends Panel

# Grid settings
var cell_size := 32
var grid_size := Vector2(10, 4)

# Signals
signal cell_highlighted(grid_pos)
signal item_dropped(grid_pos)

func _ready():
	# Set grid size
	custom_minimum_size = Vector2(grid_size.x * cell_size, grid_size.y * cell_size)
	
	# Create grid lines
	_draw_grid_lines()

func _draw_grid_lines():
	# Add grid lines for visual reference
	for x in range(grid_size.x + 1):
		var line = Line2D.new()
		line.add_point(Vector2(x * cell_size, 0))
		line.add_point(Vector2(x * cell_size, grid_size.y * cell_size))
		line.width = 1
		line.default_color = Color(0.3, 0.3, 0.3, 0.5)
		add_child(line)
	
	for y in range(grid_size.y + 1):
		var line = Line2D.new()
		line.add_point(Vector2(0, y * cell_size))
		line.add_point(Vector2(grid_size.x * cell_size, y * cell_size))
		line.width = 1
		line.default_color = Color(0.3, 0.3, 0.3, 0.5)
		add_child(line)

func _gui_input(event):
	if event is InputEventMouseMotion:
		var grid_pos = _get_grid_position(get_local_mouse_position())
		emit_signal("cell_highlighted", grid_pos)
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var grid_pos = _get_grid_position(get_local_mouse_position())
		emit_signal("item_dropped", grid_pos)

func _get_grid_position(local_pos):
	var x = int(local_pos.x / cell_size)
	var y = int(local_pos.y / cell_size)
	return Vector2(x, y)

func is_valid_grid_position(grid_pos):
	return grid_pos.x >= 0 and grid_pos.x < grid_size.x and grid_pos.y >= 0 and grid_pos.y < grid_size.y

func grid_to_pixel(grid_pos):
	return Vector2(grid_pos.x * cell_size, grid_pos.y * cell_size)