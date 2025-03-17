extends CharacterBody2D

signal boss_defeated

@export var speed = 80
@export var max_health = 30
@export var health = 30
@export var damage = 2
@export var attack_cooldown = 1.5
@export var special_attack_cooldown = 5.0

var player = null
var can_move = true
var can_attack = true
var can_special_attack = true
var rng = RandomNumberGenerator.new()
var phase = 1  # Boss has multiple phases

func _ready():
	add_to_group("enemies")
	add_to_group("boss")
	rng.randomize()
	# Start special attack timer
	_start_special_attack_timer()

func _physics_process(delta):
	if player != null and can_move:
		var direction = (player.global_position - global_position).normalized()
		
		# Phase 2 movement - faster and more erratic
		if phase == 2:
			# Occasionally move in random direction
			if rng.randf() < 0.1:
				direction = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized()
		
		velocity = direction * speed
		move_and_slide()
		
		# Attack player if in range and cooldown is over
		if can_attack and global_position.distance_to(player.global_position) < 50:
			attack()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		player = null

func take_damage(amount):
	health -= amount
	
	# Visual feedback
	$BossSprite.modulate = Color(1.5, 0.5, 0.5)  # Bright red
	await get_tree().create_timer(0.1).timeout
	$BossSprite.modulate = Color(1, 0, 0)  # Back to normal red
	
	# Phase transition at 50% health
	if health <= max_health / 2 and phase == 1:
		transition_to_phase_2()
	
	if health <= 0:
		die()

func attack():
	can_attack = false
	
	# Deal damage to player
	player.take_damage(damage)
	
	# Visual feedback
	$BossSprite.modulate = Color(1.5, 0.5, 0)  # Bright orange
	await get_tree().create_timer(0.1).timeout
	$BossSprite.modulate = Color(1, 0, 0)  # Back to normal red
	
	# Reset attack cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func special_attack():
	can_special_attack = false
	
	# Stop moving during special attack
	var was_moving = can_move
	can_move = false
	
	# Visual indicator
	$SpecialAttackIndicator.visible = true
	await get_tree().create_timer(1.0).timeout
	$SpecialAttackIndicator.visible = false
	
	# Perform special attack based on phase
	if phase == 1:
		# Phase 1 special: shock wave
		shock_wave_attack()
	else:
		# Phase 2 special: summon minions
		summon_minions()
	
	# Resume movement
	can_move = was_moving
	
	# Reset special attack cooldown timer
	_start_special_attack_timer()

func shock_wave_attack():
	# Create shockwave effect
	var shockwave = CircleShape2D.new()
	shockwave.radius = 200
	
	# Check if player is in range
	if player and global_position.distance_to(player.global_position) < 200:
		player.take_damage(damage * 2)
	
	# Visual feedback
	var shockwave_visual = Area2D.new()
	var collision = CollisionShape2D.new()
	collision.shape = shockwave
	shockwave_visual.add_child(collision)
	
	var visual = ColorRect.new()
	visual.color = Color(1, 0.5, 0, 0.3)
	visual.size = Vector2(400, 400)
	visual.position = Vector2(-200, -200)
	shockwave_visual.add_child(visual)
	
	add_child(shockwave_visual)
	
	# Animate and remove
	var tween = create_tween()
	tween.tween_property(visual, "modulate", Color(1, 0.5, 0, 0), 0.5)
	await tween.finished
	shockwave_visual.queue_free()

func summon_minions():
	# Summon 2-3 small minions
	var num_minions = rng.randi_range(2, 3)
	var minion_scene = load("res://scenes/enemy.tscn")
	
	for i in range(num_minions):
		var minion = minion_scene.instantiate()
		var minion_body = minion.get_node("CharacterBody2D")
		
		# Customize minion
		minion_body.health = 2
		minion_body.speed = 150
		minion_body.damage = 1
		
		# Position around boss
		var angle = 2 * PI * i / num_minions
		var offset = Vector2(cos(angle), sin(angle)) * 100
		minion.position = global_position + offset
		
		# Add to scene
		get_parent().add_child(minion)

func transition_to_phase_2():
	phase = 2
	speed *= 1.2
	attack_cooldown *= 0.8
	special_attack_cooldown *= 0.7
	
	# Visual change
	$BossSprite.modulate = Color(1, 0.5, 0)  # Change to orange-red
	
	# Announce phase transition
	print("Boss entered phase 2!")

func die():
	emit_signal("boss_defeated")
	queue_free()

func _start_special_attack_timer():
	var cooldown = special_attack_cooldown
	if phase == 2:
		cooldown *= 0.7  # Faster special attacks in phase 2
	
	await get_tree().create_timer(cooldown).timeout
	if is_instance_valid(self):
		can_special_attack = true
		special_attack()