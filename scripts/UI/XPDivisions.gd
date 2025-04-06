extends Control

@export var line_color: Color = Color(1.0, 1.0, 1.0, 0.4)
@export var line_thickness: float = 1.0

func _draw():
	var bar_size = size

	for i in range(1, 20):
		var percentage = float(i) * 0.05
		var x_pos = bar_size.x * percentage

		draw_line(Vector2(x_pos, 0), Vector2(x_pos, bar_size.y), line_color, line_thickness)
