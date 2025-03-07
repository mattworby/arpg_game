extends Node2D

# Sword properties
@export var damage: int = 1
@export var swing_speed: float = 0.3  # Time in seconds for a full swing
@export var swing_angle: float = 70.0  # Degrees to swing in each direction

# Animation state
var is_swinging: bool = false
var swing_time: float = 0.0
var swing_direction: int = 1  # 1 for right swing, -1 for left swing

# References
@onready var sprite = $Sprite
@onready var hit_area = $HitArea
@onready var collision_shape = $HitArea/CollisionShape2D

func _ready():
	# Initially disable the hit area
	hit_area.monitoring = false
	
	# Make sure we don't process physics when not swinging
	set_physics_process(false)

func _physics_process(delta):
	if is_swinging:
		# Update swing time
		swing_time += delta
		
		# Calculate rotation based on swing time
		var progress = min(swing_time / swing_speed, 1.0)
		var target_angle = swing_direction * swing_angle * sin(progress * PI)
		rotation_degrees = target_angle
		
		# Enable hit detection during the middle of the swing
		hit_area.monitoring = (progress > 0.25 and progress < 0.75)
		
		# End swing when complete
		if progress >= 1.0:
			end_swing()

func swing():
	if not is_swinging:
		is_swinging = true
		swing_time = 0.0
		
		# Alternate swing direction each time
		swing_direction *= -1
		
		# Enable physics processing for animation
		set_physics_process(true)
		
		# Activate collision detection
		hit_area.monitoring = true

func end_swing():
	is_swinging = false
	rotation_degrees = 0
	hit_area.monitoring = false
	set_physics_process(false)

func _on_hit_area_body_entered(body):
	# Check if we hit an enemy
	if body.get_parent().name == "Enemy":
		# Destroy the enemy
		body.queue_free()