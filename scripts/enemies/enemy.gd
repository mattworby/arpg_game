extends CharacterBody2D

@export var speed = 200  # Movement speed
@export var detection_range = 300  # Range to detect and chase player

var player = null

func _ready():
	# Set the enemy color to red
	$ColorRect.color = Color.RED
	setup_detection_area()
	
	# Set collision layer to 2 (enemies)
	collision_layer = 2
	collision_mask = 1  # Collide with world

func _physics_process(delta):
	if player:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()

# Method to set up the detection area in the Godot editor
func setup_detection_area():
	# Create an Area2D for detection
	var detection_area = Area2D.new()
	detection_area.name = "DetectionArea"
	
	# Create a CollisionShape2D
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = detection_range
	collision_shape.shape = shape
	
	# Add the collision shape to the detection area
	detection_area.add_child(collision_shape)
	add_child(detection_area)
	
	# Connect signals
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

# Signal callback when a body enters the detection area
func _on_detection_area_body_entered(body):
	# Check if the body is in the player group
	if body.is_in_group("player"):
		print("Player entered enemy detection range")
		player = body

# Signal callback when a body exits the detection area
func _on_detection_area_body_exited(body):
	# Stop tracking player when they exit the detection area
	if body == player:
		print("Player exited enemy detection range")
		player = null

func _on_area_2d_body_entered(body: Node2D) -> void:
	pass

func _on_area_2d_body_exited(body: Node2D) -> void:
	pass
