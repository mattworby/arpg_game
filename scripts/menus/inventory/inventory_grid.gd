extends Control

var _grid_size : Vector2 = Vector2(12, 6)
var _cell_size : int = 32

func set_grid_parameters(new_grid_size: Vector2, new_cell_size: int):
	_grid_size = new_grid_size
	_cell_size = new_cell_size
	queue_redraw()

func _ready():
	queue_redraw()

func _draw():
	var line_color = Color(0.3, 0.3, 0.3, 0.5)
	var line_width = 1.0

	for x in range(int(_grid_size.x) + 1):
		var start_x = float(x * _cell_size)
		var end_y = float(_grid_size.y * _cell_size)
		draw_line(Vector2(start_x, 0.0), Vector2(start_x, end_y), line_color, line_width)

	for y in range(int(_grid_size.y) + 1):
		var start_y = float(y * _cell_size)
		var end_x = float(_grid_size.x * _cell_size)
		draw_line(Vector2(0.0, start_y), Vector2(end_x, start_y), line_color, line_width)
