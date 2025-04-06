extends Node2D

@export var damage = 1
@export var swing_speed = 0.3
@export var swing_angle = 70 

var is_swinging = false
var base_position = Vector2(30, 0)
var original_scale = Vector2(1, 1)
var hit_enemies = []

func _ready():
	$HitArea.body_entered.connect(_on_hitbox_body_entered)

func swing():
	if is_swinging:
		return
	
	is_swinging = true
	hit_enemies.clear()
	
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", swing_angle, swing_speed/2)
	tween.tween_property(self, "rotation_degrees", -swing_angle, swing_speed)
	tween.tween_property(self, "rotation_degrees", 0, swing_speed/2)
	
	await tween.finished
	is_swinging = false

func _on_hitbox_body_entered(body):
	if body.is_in_group("enemies") and not body in hit_enemies and is_swinging:
		print("Hit enemy with sword")
		hit_enemies.append(body)
		
		if body.has_method("take_damage"):
			body.take_damage(damage)
