extends Node

class_name BossRoomManager

@export var boss_scene: PackedScene = preload("res://scenes/enemies/boss.tscn")

var boss_instance = null
var boss_spawned = false

signal boss_defeated

func _ready():
	call_deferred("setup_boss_room")

func setup_boss_room():
	spawn_boss()

func spawn_boss():
	if boss_spawned:
		return
		
	boss_spawned = true
	var town_scene = get_parent()
	
	# Create boss instance
	boss_instance = boss_scene.instantiate()
	
	# Position boss in center of room
	var viewport_size = get_viewport().get_visible_rect().size
	boss_instance.position = Vector2(viewport_size.x/2, viewport_size.y/2)
	
	# Connect signals
	boss_instance.get_node("CharacterBody2D").boss_defeated.connect(_on_boss_defeated)
	
	town_scene.add_child(boss_instance)

func _on_boss_defeated():
	emit_signal("boss_defeated")

# You'll need to create a boss.tscn scene that extends the enemy but is more powerful
