extends CharacterBody2D

signal enemy_died(enemy_node)

@export var speed = 200
@export var health = 3
@export var damage = 1
@export var experience = 500
@export var level = 1

var player = null
var is_dead = false

@onready var detection_area = $Area2D
@onready var visual_node = $ColorRect

func _ready():
	if not visual_node:
		push_warning("Enemy needs a visual node (e.g., ColorRect, Sprite2D) assigned to visual_node for effects.")

	add_to_group("enemies")

	collision_layer = 2
	collision_mask = 1

func _physics_process(delta):
	if player and not is_dead:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_area_2d_body_exited(body):
	if body == player:
		player = null

func take_damage(amount):
	if is_dead: return

	health -= amount

	if visual_node:
		visual_node.modulate = Color(1.5, 1.5, 1.5)
		await get_tree().create_timer(0.08).timeout
		visual_node.modulate = Color(1, 1, 1)

	if health <= 0:
		die()

func die():
	if is_dead: return
	is_dead = true

	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	if $CollisionShape2D: $CollisionShape2D.disabled = true
	velocity = Vector2.ZERO

	enemy_died.emit(self)

	if visual_node:
		var tween = create_tween().set_parallel(false)
		tween.tween_property(visual_node, "modulate", Color(1,1,1,0), 0.4).set_ease(Tween.EASE_IN)
		await tween.finished

	queue_free()
