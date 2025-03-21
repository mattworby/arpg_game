extends CharacterBody2D

signal health_changed(current_health, max_health)
signal mana_changed(current_mana, max_mana)
signal player_died

@export var speed = 300  # Movement speed
@export var max_health = 100
@export var max_mana = 100
var health = max_health
var mana = max_mana
var mouse_target = null  # For mouse movement tracking
var can_move = true  # Control movement ability
var sword_scene = preload("res://scenes/weapons/sword.tscn")  # Preload the sword scene
var sword = null  # Reference to the sword instance
var is_following_mouse = false  # Track if we're in mouse following mode
var current_building = null  # Track which building the player is inside

func _ready():
	# Set the player color to blue
	$HitArea.body_entered.connect(_on_hitbox_body_entered)
	$ColorRect.color = Color.BLUE
	set_process_input(true)
	add_to_group("player")
	
	# Add the sword
	sword = sword_scene.instantiate()
	sword.position = Vector2(30, 0)  # Position it on the right side of the player
	add_child(sword)
	
	# Initialize health and mana
	health = max_health
	mana = max_mana
	emit_signal("health_changed", health, max_health)
	emit_signal("mana_changed", mana, max_mana)

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
		
		# Slowly regenerate mana over time
		regenerate_mana(0.1 * delta)

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
				# Use mana for sword swing
				if use_mana(10):  # Use 10 mana per swing
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

func _on_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		take_damage(1)

# Health system methods
func take_damage(amount):
	health -= amount
	health = max(0, health)  # Prevent negative health
	emit_signal("health_changed", health, max_health)
	
	if health <= 0:
		die()

func heal(amount):
	health += amount
	health = min(health, max_health)  # Cap at max health
	emit_signal("health_changed", health, max_health)

# Mana system methods
func use_mana(amount):
	if mana >= amount:
		mana -= amount
		mana = max(0, mana)  # Prevent negative mana
		emit_signal("mana_changed", mana, max_mana)
		return true
	return false

func regenerate_mana(amount):
	mana += amount
	mana = min(mana, max_mana)  # Cap at max mana
	emit_signal("mana_changed", mana, max_mana)

func die():
	# Player death handling
	lock_movement()
	# You might want to add death animation here
	emit_signal("player_died")
