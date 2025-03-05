extends CharacterBody2D

@export var speed = 300  # Movement speed
var mouse_target = null  # For mouse movement tracking
var can_move = true  # Control movement ability

func _ready():
	# Set the player color to blue
	$ColorRect.color = Color.BLUE
	set_process_input(true)
	add_to_group("player")

func _physics_process(delta):
	# Only process movement if movement is allowed
	if can_move:
		# WASD Movement
		var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		
		# Mouse Movement Priority
		if mouse_target:
			input_vector = global_position.direction_to(mouse_target)
			
			# Stop when close to mouse target
			if global_position.distance_to(mouse_target) < 10:
				input_vector = Vector2.ZERO
				mouse_target = null
		
		# Calculate velocity
		velocity = input_vector * speed
		move_and_slide()

func _input(event):
	
	# Handle mouse click for movement
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Get the mouse position in world coordinates
			mouse_target = get_global_mouse_position()

# Method to lock player movement
func lock_movement():
	can_move = false
	velocity = Vector2.ZERO  # Stop any current movement
	mouse_target = null  # Clear any pending mouse movement

# Method to unlock player movement
func unlock_movement():
	can_move = true
