extends Area2D

class_name Door

signal door_entered(door_name)

@export var building_name: String = "Building"
@export var door_width: float = 40
@export var door_height: float = 60
@export var highlight_color: Color = Color(1, 1, 0, 0.5)  # Yellow semi-transparent highlight
@export var interior_scene_path: String = "res://scenes/interior_scene.tscn"

var player_in_range: bool = false
var is_highlighted: bool = false
var door_rect: ColorRect
var highlight_rect: ColorRect
var collision_shape: CollisionShape2D

func _ready():
	# Create door visual
	door_rect = ColorRect.new()
	door_rect.size = Vector2(door_width, door_height)
	door_rect.color = Color(0.4, 0.2, 0.1, 1)  # Brown door color
	add_child(door_rect)
	
	# Center the door rect
	door_rect.position = Vector2(-door_width/2, -door_height/2)
	
	# Create highlight overlay (initially invisible)
	highlight_rect = ColorRect.new()
	highlight_rect.size = Vector2(door_width, door_height)
	highlight_rect.color = highlight_color
	highlight_rect.visible = false
	add_child(highlight_rect)
	
	# Center the highlight rect
	highlight_rect.position = Vector2(-door_width/2, -door_height/2)
	
	# Setup collision shape
	collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(door_width, door_height)
	collision_shape.shape = shape
	add_child(collision_shape)
	
	# Connect signals
	body_entered.connect(_on_door_body_entered)
	mouse_entered.connect(_on_door_mouse_entered)
	mouse_exited.connect(_on_door_mouse_exited)
	
	# Enable input processing
	set_process_input(true)

func _input(event):
	# Check for mouse click on the door
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_highlighted:
		# Get player reference
		var player = get_node("/root/TownScene/Player/CharacterBody2D")
		if player:
			# Calculate door's world position for the player to move to
			var door_pos = global_position
			# Set the player's target to the door position
			player.mouse_target = door_pos
			print("Player moving to door: ", building_name)

func _on_door_body_entered(body):
	if body.is_in_group("player"):
		print("Player entered door: ", building_name)
		player_in_range = true
		
		# Change to the interior scene
		# In a real game, you might want to use a transition effect
		var scene_tree = get_tree()
		scene_tree.change_scene_to_file(interior_scene_path)

func _on_door_mouse_entered():
	is_highlighted = true
	highlight_rect.visible = true
	print("Mouse hovering over door: ", building_name)

func _on_door_mouse_exited():
	is_highlighted = false
	highlight_rect.visible = false
