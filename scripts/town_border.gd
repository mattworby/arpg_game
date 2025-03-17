extends Node2D

class_name TownBorder

@export var border_width: float = 10.0
@export var border_color: Color = Color(0.6, 0.4, 0.2, 1.0)
@export var town_width: float = 1200.0
@export var town_height: float = 700.0

func _ready():
	# Create the border visuals and collision
	create_border()

func create_border():
	# Create the visual border
	create_border_segment(Vector2(0, 0), Vector2(town_width, 0))  # Top
	create_border_segment(Vector2(0, 0), Vector2(0, town_height))  # Left
	create_border_segment(Vector2(town_width, 0), Vector2(town_width, town_height))  # Right

	create_border_segment(Vector2(0, town_height), Vector2(town_width, town_height))  # Bottom

func create_border_segment(start: Vector2, end: Vector2):
	# Create visual border
	var segment = Line2D.new()
	segment.width = border_width
	segment.default_color = border_color
	segment.add_point(start)
	segment.add_point(end)
	add_child(segment)
	
	# Create collision body
	var static_body = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = SegmentShape2D.new()
	shape.a = start
	shape.b = end
	collision.shape = shape
	static_body.add_child(collision)
	add_child(static_body)
