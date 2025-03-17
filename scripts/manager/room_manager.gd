extends Node

class_name RoomManager

@export var enemy_scene: PackedScene
@export var consumable_scene: PackedScene
@export var min_enemies: int = 3
@export var max_enemies: int = 6

var current_room_enemies = []
var all_enemies_defeated = false
var consumable_spawned = false
var rng = RandomNumberGenerator.new()

signal all_enemies_defeated_signal
signal room_completed

func _ready():
	rng.randomize()
	# Get reference to the town scene (parent)
	var town_scene = get_parent()
	
	# Set up room bounds based on viewport
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Generate room contents
	call_deferred("generate_room", town_scene)

func generate_room(town_scene):
	clear_room(town_scene)
	spawn_enemies(town_scene)
	all_enemies_defeated = false
	consumable_spawned = false

func clear_room(town_scene):
	# Remove any existing enemies
	for enemy in current_room_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	current_room_enemies.clear()
	
	# Remove any existing consumables
	var existing_consumables = get_tree().get_nodes_in_group("consumables")
	for consumable in existing_consumables:
		consumable.queue_free()

func spawn_enemies(town_scene):
	var num_enemies = rng.randi_range(min_enemies, max_enemies)
	var viewport_size = get_viewport().get_visible_rect().size
	
	for i in range(num_enemies):
		var enemy = enemy_scene.instantiate()
		var enemy_body = enemy.get_node("CharacterBody2D")
		
		# Set random position within room boundaries (with padding)
		var padding = 50
		var x_pos = rng.randf_range(padding, viewport_size.x - padding)
		var y_pos = rng.randf_range(padding, viewport_size.y - padding)
		enemy.position = Vector2(x_pos, y_pos)
		
		# Connect enemy defeated signal
		enemy_body.enemy_defeated.connect(_on_enemy_defeated)
		
		# Add to tracking list and scene
		current_room_enemies.append(enemy_body)
		town_scene.add_child(enemy)

func _on_enemy_defeated(enemy):
	# Remove enemy from the tracking list
	current_room_enemies.erase(enemy)
	
	# Check if all enemies are defeated
	if current_room_enemies.size() == 0 and not all_enemies_defeated:
		all_enemies_defeated = true
		emit_signal("all_enemies_defeated_signal")
		spawn_consumable()

func spawn_consumable():
	if consumable_spawned:
		return
		
	consumable_spawned = true
	var town_scene = get_parent()
	var consumable = consumable_scene.instantiate()
	
	# Position in center of room
	var viewport_size = get_viewport().get_visible_rect().size
	consumable.position = Vector2(viewport_size.x/2, viewport_size.y/2)
	
	# Connect the consumed signal
	consumable.consumed.connect(_on_consumable_consumed)
	
	town_scene.add_child(consumable)

func _on_consumable_consumed(_upgrade_type):
	emit_signal("room_completed")
