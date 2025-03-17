extends CharacterBody2D

@export var speed = 200  # Movement speed
@export var detection_range = 300  # Range to detect and chase player
@export var health = 3  # Enemy health
@export var damage = 1  # Damage dealt to player

var player = null
var is_dead = false

func _ready():
	# Set the enemy color to red
	$ColorRect.color = Color.RED
	add_to_group("enemies")
	
	# Set collision layer to 2 (enemies)
	collision_layer = 2
	collision_mask = 1  # Collide with world

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
	
	# Visual feedback
	$ColorRect.modulate = Color(1.5, 1.5, 1.5)  # Flash bright
	await get_tree().create_timer(0.1).timeout
	$ColorRect.modulate = Color(1, 1, 1)  # Back to normal
	
	if health <= 0 and !is_dead:
		die()

func die():
	is_dead = true
	
	# Visual effect before removing
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate", Color(1,1,1,0), 0.3)
	
	# Wait for animation then remove
	await tween.finished
	queue_free()  # This will trigger the tree_exited signal
