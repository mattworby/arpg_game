extends CharacterBody2D

@export var speed = 300  # Movement speed
var mouse_target = null  # For mouse movement tracking
var can_move = true  # Control movement ability
var sword_scene = preload("res://scenes/sword.tscn")  # Preload the sword scene
var sword = null  # Reference to the sword instance
var is_following_mouse = false  # Track if we're in mouse following mode
var current_building = null  # Track which building the player is inside

func _ready():
	# Set the player color to blue
	$ColorRect.color = Color.BLUE
	set_process_input(true)
	add_to_group("player")
	
	# Add the sword
	sword = sword_scene.instantiate()
	sword.position = Vector2(30, 0)  # Position it on the right side of the player
	add_child(sword)

func _physics_process(delta):
	# Only process movement if movement is allowed
	if can_move:
		# Update mouse target if following mouse
		if is_following_mouse:
			mouse_target = get_global_mouse_position()
			
		# WASD Movement
		var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		
		# Mouse Movement Priority
		if mouse_target:
			input_vector = global_position.direction_to(mouse_target)
			
			# Stop when close to mouse target
			if global_position.distance_to(mouse_target) < 10:
				input_vector = Vector2.ZERO
				# Only clear target if not in following mode
				if not is_following_mouse:
					mouse_target = null
		
		# Calculate velocity
		velocity = input_vector * speed
		move_and_slide()
		
		# Update sword direction to face mouse
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down") or mouse_target:
			update_sword_direction()

func _input(event):
	# Handle mouse button for movement
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start following the mouse
				is_following_mouse = true
				mouse_target = get_global_mouse_position()
			else:
				# Stop following the mouse when button is released
				is_following_mouse = false
		
		# Handle right-click for sword swing
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if sword and can_move:
				sword.swing()
	
	# Update mouse position when moving mouse
	elif event is InputEventMouseMotion and is_following_mouse:
		mouse_target = get_global_mouse_position()
		
	# Handle building exit with ESC key
	elif event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE and current_building:
			exit_building()

# Method to lock player movement
func lock_movement():
	can_move = false
	velocity = Vector2.ZERO  # Stop any current movement
	mouse_target = null  # Clear any pending mouse movement
	is_following_mouse = false  # Stop following mouse

# Method to unlock player movement
func unlock_movement():
	can_move = true

# Method to update sword direction based on player movement or mouse position
func update_sword_direction():
	if sword:
		# Get mouse position
		var mouse_pos = get_global_mouse_position()
		
		# Calculate direction to mouse
		var direction = global_position.direction_to(mouse_pos)
		
		# Update sword position to always be on the side facing the mouse
		sword.position = direction * 30
		
		# Flip the sword based on direction
		if direction.x < 0:
			sword.scale.y = -1
		else:
			sword.scale.y = 1

# Method to enter a building
func enter_building(building):
	current_building = building

# Method to exit the current building
func exit_building():
	if current_building:
		current_building.toggle_building_entry()
		current_building = null
