extends Node

class_name RoomGenerator

# Configuration
@export var min_enemies: int = 3
@export var max_enemies: int = 6
@export var room_size: Vector2 = Vector2(1000, 600)
@export var spawn_delay: float = 1.0  # Seconds between enemy spawns
@export var enemy_scene: PackedScene
@export var player_scene: PackedScene

# Tracking
var enemies_to_spawn: int = 0
var enemies_spawned: int = 0
var enemies_defeated: int = 0
var spawn_timer: Timer
var player_instance = null
var active_enemies = []

signal room_cleared

func _ready():
	randomize()
	spawn_timer = Timer.new()
	spawn_timer.one_shot = false
	spawn_timer.wait_time = spawn_delay
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

func generate_room(player_ref = null):
	# Clear any existing enemies
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	active_enemies.clear()
	
	# Set up the room
	enemies_to_spawn = randi_range(min_enemies, max_enemies)
	enemies_spawned = 0
	enemies_defeated = 0
	
	# Spawn player if none provided
	if player_ref:
		player_instance = player_ref
	else:
		player_instance = player_scene.instantiate()
		player_instance.position = Vector2(room_size.x / 2, room_size.y / 2)
		add_child(player_instance)
	
	# Start spawning enemies
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if enemies_spawned < enemies_to_spawn:
		spawn_enemy()
	else:
		spawn_timer.stop()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	
	# Set random position away from player
	var spawn_position = Vector2.ZERO
	var min_distance = 150  # Minimum distance from player
	var max_attempts = 10
	
	for i in range(max_attempts):
		spawn_position = Vector2(
			randf_range(50, room_size.x - 50),
			randf_range(50, room_size.y - 50)
		)
		
		if spawn_position.distance_to(player_instance.position) >= min_distance:
			break
	
	enemy.position = spawn_position
	
	# Get the character body
	var enemy_body = enemy.get_node("CharacterBody2D")
	if enemy_body:
		# Add custom script to track death
		enemy_body.set_meta("enemy_id", enemies_spawned)
		
		# Create a custom signal for this enemy's death
		if !enemy_body.has_user_signal("enemy_died"):
			enemy_body.add_user_signal("enemy_died")
		
		# Connect a method to detect when this enemy is freed
		if !enemy_body.is_connected("tree_exited", _on_enemy_defeated):
			enemy_body.tree_exited.connect(_on_enemy_defeated.bind(enemies_spawned))
		
		# Add to tracking list
		active_enemies.append(enemy_body)
	
	add_child(enemy)
	enemies_spawned += 1

func _on_enemy_defeated(enemy_id = -1):
	enemies_defeated += 1
	print("Enemy defeated: " + str(enemies_defeated) + "/" + str(enemies_to_spawn))
	
	if enemies_defeated >= enemies_to_spawn:
		print("win")  # Console log "win" as requested
		emit_signal("room_cleared")
