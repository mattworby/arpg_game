extends CharacterBody2D

@export var interaction_range: float = 100  # Range to interact with player
@export_multiline var dialog_text: String = "Hello World"  # Multiline export for longer text
@export var dialog_title: String = "NPC"  # Optional title for the dialog

# Reference to the dialog container
var dialog_container

# Reference to the player
var player
var player_in_range = false

func _ready():
	# Set the NPC color to gray
	$ColorRect.color = Color.GRAY
	setup_interaction_area()
	
	# Add to NPC group
	add_to_group("npcs")
	
	# Find the dialog container
	dialog_container = get_node_or_null("/root/TownScene/DialogBox/CanvasLayer/DialogContainer")
	if dialog_container == null:
		dialog_container = get_node_or_null("/root/MainScene/DialogBox/CanvasLayer/DialogContainer")
	
	# Connect dialog finished signal if dialog container exists
	if dialog_container:
		if !dialog_container.is_connected("dialog_finished", Callable(self, "_on_dialog_finished")):
			dialog_container.connect("dialog_finished", Callable(self, "_on_dialog_finished"))

func _input(event):
	# Check if player is in range and clicked on NPC
	if player_in_range and (event is InputEventMouseButton or event is InputEventKey):
		var interact = false
		
		# Check for left mouse click
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				# Get mouse position in world coordinates
				var mouse_pos = get_global_mouse_position()
				
				# Check if mouse is over the NPC
				if get_global_rect().has_point(mouse_pos):
					interact = true
					
		# Check for E key press
		elif event is InputEventKey:
			if event.pressed and event.keycode == KEY_E:
				interact = true
				
		if interact:
			show_dialog()

func setup_interaction_area():
	# Create an Area2D for interaction if it doesn't exist
	if not has_node("Area2D"):
		# Create an Area2D for interaction
		var interaction_area = Area2D.new()
		interaction_area.name = "Area2D"
		
		# Create a CollisionShape2D
		var collision_shape = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = interaction_range
		collision_shape.shape = shape
		collision_shape.position = Vector2(20, 20)  # Center on the NPC
		
		# Add the collision shape to the interaction area
		interaction_area.add_child(collision_shape)
		add_child(interaction_area)
		
		# Connect signals
		interaction_area.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))
		interaction_area.connect("body_exited", Callable(self, "_on_area_2d_body_exited"))

func _on_area_2d_body_entered(body):
	# Check if the body is the player
	if body.is_in_group("player"):
		print("Player entered NPC interaction range")
		player_in_range = true
		player = body
		
		# Show interaction prompt
		if dialog_container:
			dialog_container.show_dialog("Press E to talk to " + dialog_title, "Interaction")

func _on_area_2d_body_exited(body):
	# Check if the exiting body is the player
	if body.is_in_group("player") and body == player:
		print("Player exited NPC interaction range")
		player_in_range = false
		
		# Hide interaction prompt
		if dialog_container:
			dialog_container.hide_dialog()

func show_dialog():
	if dialog_container and player:
		# Lock player movement completely
		player.lock_movement()
		
		# Show dialog
		dialog_container.show_dialog(dialog_text, dialog_title)

func _on_dialog_finished():
	# Unlock player movement
	if player:
		player.unlock_movement()

func get_global_rect():
	# Get the global rectangle of the NPC for click detection
	var rect = $ColorRect.get_global_rect()
	return rect
