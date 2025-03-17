extends Node2D

@export var damage = 1
@export var swing_speed = 0.3  # Time in seconds for a swing
@export var swing_angle = 70  # Degrees to swing in each direction

var is_swinging = false
var base_position = Vector2(30, 0)
var original_scale = Vector2(1, 1)
var hit_enemies = []

func _ready():
	var hitbox = $HitArea
	hitbox.body_entered.connect(_on_hitbox_body_entered)

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
	if body.is_in_group("enemies") and not body in hit_enemies and is_swinging:
		print("Hit enemy with sword")
		hit_enemies.append(body)  # Add to hit list for this swing
		
		# Apply damage if the enemy has a take_damage method
		if body.has_method("take_damage"):
			body.take_damage(damage)
