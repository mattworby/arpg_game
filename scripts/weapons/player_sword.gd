extends Node2D

@export var damage = 1
@export var swing_speed = 0.3  # Time in seconds for a swing
@export var swing_angle = 70  # Degrees to swing in each direction

var is_swinging = false
var base_position = Vector2(30, 0)
var original_scale = Vector2(1, 1)
var hit_enemies = []

func _ready():
	# Add a visual representation
	var sword_visual = ColorRect.new()
	sword_visual.size = Vector2(40, 10)
	sword_visual.position = Vector2(0, -5)
	sword_visual.color = Color(0.8, 0.8, 0.8)
	sword_visual.name = "SwordVisual"
	add_child(sword_visual)
	
	# Add a hitbox area
	var hitbox = Area2D.new()
	hitbox.name = "Hitbox"
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(40, 20)
	collision.shape = shape
	collision.position = Vector2(20, 0)
	
	hitbox.add_child(collision)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	add_child(hitbox)
	
	# Store original scale
	original_scale = scale

func swing():
	if is_swinging:
		return  # Don't allow swing spam
	
	is_swinging = true
	hit_enemies.clear()  # Reset hit enemies for this swing
	
	# Create the swing animation
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", swing_angle, swing_speed/2)
	tween.tween_property(self, "rotation_degrees", -swing_angle, swing_speed)
	tween.tween_property(self, "rotation_degrees", 0, swing_speed/2)
	
	await tween.finished
	is_swinging = false

func _on_hitbox_body_entered(body):
	# Check if body is an enemy and hasn't been hit yet in this swing
	if body.is_in_group("enemies") and not body in hit_enemies and is_swinging:
		print("Hit enemy with sword")
		hit_enemies.append(body)  # Add to hit list for this swing
		
		# Apply damage if the enemy has a take_damage method
		if body.has_method("take_damage"):
			body.take_damage(damage)
