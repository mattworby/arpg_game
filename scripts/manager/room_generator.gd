extends Node

class_name RoomGenerator

@export var min_enemies: int = 3
@export var max_enemies: int = 6
@export var room_size: Vector2 = Vector2(1000, 600)
@export var spawn_delay: float = 0.5 
@export var enemy_scene: PackedScene

var enemies_to_spawn: int = 0
var enemies_spawned: int = 0
var spawn_timer: Timer
var player_instance_body = null
var active_enemies: Array[Node] = []

signal room_cleared

func _ready():
	randomize()
	spawn_timer = Timer.new()
	spawn_timer.name = "SpawnTimer"
	spawn_timer.one_shot = false
	spawn_timer.wait_time = spawn_delay
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

func generate_room(player_body_ref: CharacterBody2D):
	print("RoomGenerator: Generating room...")
	for enemy_root in active_enemies:
		if is_instance_valid(enemy_root):
			enemy_root.queue_free()
	active_enemies.clear()

	if not is_instance_valid(player_body_ref):
		push_error("RoomGenerator: Invalid player reference passed.")
		return

	player_instance_body = player_body_ref

	enemies_to_spawn = randi_range(min_enemies, max_enemies)
	enemies_spawned = 0
	print("RoomGenerator: Will spawn %d enemies." % enemies_to_spawn)

	if enemies_to_spawn > 0:
		spawn_timer.start()
	else:
		print("RoomGenerator: No enemies to spawn, room clear.")
		emit_signal("room_cleared")


func _on_spawn_timer_timeout():
	if enemies_spawned < enemies_to_spawn:
		spawn_enemy()
	else:
		print("RoomGenerator: Finished spawning %d enemies." % enemies_spawned)
		spawn_timer.stop()
		check_if_room_clear()

func spawn_enemy():
	if not enemy_scene:
		push_error("RoomGenerator: Enemy scene not set!")
		spawn_timer.stop()
		return
	if not is_instance_valid(player_instance_body):
		push_error("RoomGenerator: Player instance body became invalid during spawning!")
		spawn_timer.stop()
		return

	var enemy_root_node = enemy_scene.instantiate()

	var spawn_position = Vector2.ZERO
	var min_distance = 150
	var max_attempts = 10
	for i in range(max_attempts):
		if room_size.x <= 100 or room_size.y <= 100:
			spawn_position = Vector2(randf() * room_size.x, randf() * room_size.y)
		else:
			spawn_position = Vector2(randf_range(50, room_size.x - 50), randf_range(50, room_size.y - 50))
		if spawn_position.distance_to(player_instance_body.global_position) >= min_distance:
			break
	if enemy_root_node is Node2D:
		enemy_root_node.global_position = spawn_position
	else:
		push_warning("Spawned enemy root node is not Node2D, cannot set position.")

	var parent_node = get_parent()
	if not is_instance_valid(parent_node):
		push_error("RoomGenerator has no valid parent! Cannot add enemy or connect signals.")
		enemy_root_node.queue_free()
		spawn_timer.stop()
		return
	parent_node.add_child(enemy_root_node)

	active_enemies.append(enemy_root_node)
	enemies_spawned += 1
	print("RoomGenerator: Spawned enemy %d/%d. Root node: %s" % [enemies_spawned, enemies_to_spawn, enemy_root_node.name])

	var enemy_body = enemy_root_node.find_child("*CharacterBody2D*", true, false)

	if is_instance_valid(enemy_body):
		if enemy_body.has_signal("enemy_died"):
			var target_node = GameManager
			var target_method_name = "handle_enemy_death"

			if target_node.has_method(target_method_name):
				var callable_to_connect = Callable(target_node, target_method_name).bind(parent_node)

				var connection_status = enemy_body.connect("enemy_died", callable_to_connect)
				if connection_status != OK:
					push_error("RoomGenerator: Failed to connect enemy_died signal for %s to GameManager. Error: %s" % [enemy_root_node.name, str(connection_status)])
			
			else:
				push_error("GameManager is missing the required method: %s" % target_method_name)
		else:
			push_warning("RoomGenerator: Enemy body in %s lacks 'enemy_died' signal." % enemy_root_node.name)
	else:
		push_warning("RoomGenerator: Could not find CharacterBody2D in spawned enemy %s to connect signal." % enemy_root_node.name)

func enemy_was_defeated(enemy_body_node: CharacterBody2D):
	if not is_instance_valid(enemy_body_node):
		print("RoomGenerator: Received defeat notification for an invalid node.")
		return

	var root_node_to_remove = null
	for root_node in active_enemies:
		if is_instance_valid(root_node) and enemy_body_node.get_parent() == root_node:
			root_node_to_remove = root_node
			break

	if root_node_to_remove:
		if root_node_to_remove in active_enemies:
			active_enemies.erase(root_node_to_remove)
			print("RoomGenerator: Notified of enemy defeat. Active list size: %d" % active_enemies.size())
		else:
			print("RoomGenerator: Notified of enemy defeat, but its root node was not found in active list.")
	else:
		print("RoomGenerator: Notified of enemy defeat, but couldn't link body node back to a tracked root node.")


	check_if_room_clear()

func check_if_room_clear():
	if not spawn_timer.is_stopped(): return
	if active_enemies.is_empty():
		print("RoomGenerator: All spawned enemies defeated! Emitting room_cleared.")
		emit_signal("room_cleared")
