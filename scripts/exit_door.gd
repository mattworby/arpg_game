extends Area2D

@export var highlight_color: Color = Color(1, 1, 0, 0.5)
@export var exterior_scene_path: String = "res://scenes/town_scene.tscn"

var player_in_range: bool = false
var is_highlighted: bool = false
var highlight_rect: ColorRect

func _ready():
	# Get the door visual rect
	var door_rect = $ColorRect
	
	# Create highlight overlay (initially invisible)
	highlight_rect = ColorRect.new()
	highlight_rect.size = door_rect.size
	highlight_rect.position = door_rect.position
	highlight_rect.color = highlight_color
	highlight_rect.visible = false
	add_child(highlight_rect)
	
	# Connect signals
	body_entered.connect(_on_exit_door_body_entered)
	mouse_entered.connect(_on_exit_door_mouse_entered)
	mouse_exited.connect(_on_exit_door_mouse_exited)
	
	# Enable input processing
	set_process_input(true)

func _input(event):
	# Check for mouse click on the door
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_highlighted:
		# Get player reference
		var player = get_node("/root/InteriorScene/Player/CharacterBody2D")
		if player:
			# Set the player's target to the door position
			player.mouse_target = global_position
			print("Player moving to exit door")

func _on_exit_door_body_entered(body):
	if body.is_in_group("player"):
		print("Player entered exit door")
		player_in_range = true
		
		# Change back to the town scene
		var scene_tree = get_tree()
		scene_tree.change_scene_to_file(exterior_scene_path)

func _on_exit_door_mouse_entered():
	is_highlighted = true
	highlight_rect.visible = true
	print("Mouse hovering over exit door")

func _on_exit_door_mouse_exited():
	is_highlighted = false
	highlight_rect.visible = false
