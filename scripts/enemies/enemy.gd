extends CharacterBody2D

@export var speed = 200
@export var detection_range = 300
@export var health = 3
@export var damage = 1
@export var experience = 500

var player = null
var is_dead = false

func _ready():
	$ColorRect.color = Color.RED
	add_to_group("enemies")
	
	collision_layer = 2
	collision_mask = 1

func _physics_process(delta):
	if player and !is_dead:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player = body
		print("Player detected by enemy")

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		player = null

func take_damage(amount):
	health -= amount
	
	$ColorRect.modulate = Color(1.5, 1.5, 1.5)
	await get_tree().create_timer(0.1).timeout
	$ColorRect.modulate = Color(1, 1, 1)
	
	if health <= 0 and !is_dead:
		die()

func die():
	PlayerData.add_experience(experience)
	is_dead = true
	
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate", Color(1,1,1,0), 0.3)
	
	await tween.finished
	queue_free()
