extends Area2D

class_name Door

signal door_entered(door_name)

@export var building_name: String = ""
@export var door_width: float = 40
@export var door_height: float = 60
@export var highlight_color: Color = Color(1, 1, 0, 0.5)
@export var interior_scene_path: String = "res://scenes/interior_scene.tscn"

var player_in_range: bool = false
var is_highlighted: bool = false
var door_rect: ColorRect
var highlight_rect: ColorRect
var collision_shape: CollisionShape2D

func _ready():
	# Door visual setup code...
	door_rect = ColorRect.new()
	door_rect.size = Vector2(door_width, door_height)
	door_rect.color = Color(0.4, 0.2, 0.1, 1)
	add_child(door_rect)
	
	door_rect.position = Vector2(-door_width/2, -door_height/2)
	
	highlight_rect = ColorRect.new()
	highlight_rect.size = Vector2(door_width, door_height)
	highlight_rect.color = highlight_color
	highlight_rect.visible = false
	add_child(highlight_rect)
	
	highlight_rect.position = Vector2(-door_width/2, -door_height/2)
	
	collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(door_width, door_height)
	collision_shape.shape = shape
	add_child(collision_shape)
	
	body_entered.connect(_on_door_body_entered)
	mouse_entered.connect(_on_door_mouse_entered)
	mouse_exited.connect(_on_door_mouse_exited)
	
	set_process_input(true)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_highlighted:
		# Find player using get_tree instead of absolute path
		var player = get_tree().get_nodes_in_group("player")[0]
		if player:
			player.mouse_target = global_position
			print("Player moving to door: ", building_name)

func _on_door_body_entered(body):
	if body.is_in_group("player"):
		print("Player entered door: ", building_name)
		player_in_range = true
		
		# Store the building name in the global script
		Global.current_building_name = building_name
		print("Set current building to: ", building_name)
		
		call_deferred("_change_scene")
		
func _change_scene():
	get_tree().change_scene_to_file(interior_scene_path)

func _on_door_mouse_entered():
	is_highlighted = true
	highlight_rect.visible = true
	print("Mouse hovering over door: ", building_name)

func _on_door_mouse_exited():
	is_highlighted = false
	highlight_rect.visible = false
