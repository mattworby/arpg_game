extends CharacterBody2D

@export var interaction_range: float = 100  # Range to interact with player
@export_multiline var dialog_text: String = "Hello World"  # Multiline export for longer text
@export var dialog_title: String = "NPC"  # Optional title for the dialog

# Reference to the dialog container
@onready var dialog_container = get_node("/root/MainScene/DialogBox/CanvasLayer/DialogContainer")

# Reference to the player (assuming it's in the scene)
@onready var player = get_node("/root/MainScene/Player/CharacterBody2D")

var player_in_range = false

func _ready():
	# Set the NPC color to gray
	$ColorRect.color = Color.GRAY
	setup_interaction_area()
	
	# Connect dialog finished signal
	dialog_container.connect("dialog_finished", Callable(self, "_on_dialog_finished"))

func _input(event):
	# Check if player is in range and clicked on NPC
	if player_in_range and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Get mouse position in world coordinates
			var mouse_pos = get_global_mouse_position()
			
			# Check if mouse is over the NPC
			if get_global_rect().has_point(mouse_pos):
				show_dialog()

func setup_interaction_area():
	# Create an Area2D for interaction
	var interaction_area = Area2D.new()
	interaction_area.name = "InteractionArea"
	
	# Create a CollisionShape2D
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = interaction_range
	collision_shape.shape = shape
	
	# Add the collision shape to the interaction area
	interaction_area.add_child(collision_shape)
	add_child(interaction_area)
	
	# Connect signals
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)

func _on_interaction_area_body_entered(body):
	# Check if the body is in the player group
	if body.is_in_group("player"):
		print("Player entered NPC interaction range")
		player_in_range = true

func _on_interaction_area_body_exited(body):
	# Check if the exiting body is the player
	if body.is_in_group("player"):
		print("Player exited NPC interaction range")
		player_in_range = false

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
