extends Node

@export var enemy_scene: PackedScene

var room_generator
var current_room: int = 1
var player_instance = null

func _ready():
	# Initialize room generator
	room_generator = RoomGenerator.new()
	room_generator.enemy_scene = enemy_scene
	room_generator.room_size = Vector2(get_viewport().size)
	room_generator.room_cleared.connect(_on_room_cleared)
	add_child(room_generator)
	
	# Set up UI
	$UI/GameHUD/RoomCounter.text = "Room: " + str(current_room)
	
	# Hide end screens
	$UI/GameOverScreen.visible = false
	
	# Find or create player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_instance = players[0]
	else:
		# Load player scene and spawn if not found
		var player_scene = load("res://scenes/player/player.tscn")
		player_instance = player_scene.instantiate()
		player_instance.position = $SpawnPositions/PlayerSpawnPoint.position
		add_child(player_instance)

	
	# Start first room
	generate_room()

func generate_room():
	# Pass the player's CharacterBody2D to the room generator
	var player_body = player_instance.get_node("CharacterBody2D")
	room_generator.generate_room(player_body)

func _on_room_cleared():
	print("Room " + str(current_room) + " cleared!")
	
	# Here you can add logic to move to the next room
	current_room += 1
	$UI/GameHUD/RoomCounter.text = "Room: " + str(current_room)
	
	# For testing, generate a new room after a delay
	# await get_tree().create_timer(2.0).timeout
	generate_room()

func _on_player_health_changed(current_health, max_health):
	$UI/GameHUD/PlayerStats/HealthLabel.text = "Health: " + str(current_health) + "/" + str(max_health)

func _on_player_died():
	$UI/GameOverScreen/VBoxContainer/RoomsReachedLabel.text = "Rooms reached: " + str(current_room)
	$UI/GameOverScreen.visible = true

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_town/town_scene.tscn")
