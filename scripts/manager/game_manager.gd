extends Node

class_name GameManager

@export var enemy_scene: PackedScene
@export var consumable_scene: PackedScene
@export var boss_scene: PackedScene = preload("res://scenes/enemies/boss.tscn")

var current_room_instance = null
var current_room_manager = null
var room_count = 0
var boss_room = 10 # First boss appears after 10 rooms
var player_instance = null

signal game_over
signal boss_defeated

func _ready():

	# Start the game
	start_game()

func start_game():
	# Reset game state
	room_count = 0
	
	# Hide UI screens
	$UI/GameOverScreen.visible = false
	$UI/VictoryScreen.visible = false
	$UI/GameHUD.visible = true
	
	# Start first room
	spawn_next_room()

func spawn_next_room():
	# Clear existing room if any
	if current_room_instance:
		current_room_instance.queue_free()
		current_room_instance = null
		current_room_manager = null
	
	room_count += 1
	
	# Update room counter in UI
	$UI/GameHUD/RoomCounter.text = "Room: " + str(room_count)
	
	# Check if it's time for boss room
	if room_count == boss_room:
		spawn_boss_room()
	else:
		spawn_regular_room()

func spawn_regular_room():
	# Instantiate the basic level scene
	var room_scene = load("res://scenes/first_area/basic_level.tscn")
	current_room_instance = room_scene.instantiate()
	add_child(current_room_instance)
	
	# If this is the first room, instantiate player
	# Otherwise, get the player from the previous room and move them to this room
	var player = null
	if room_count == 1:
		player = current_room_instance.get_node("Player")
		player_instance = player
		player.add_to_group("player")
		# Connect player signals
		player.health_changed.connect(_on_player_health_changed)
		player.player_died.connect(_on_player_died)
	else:
		# Remove existing player from previous room first
		if is_instance_valid(player_instance) and player_instance.get_parent():
			player_instance.get_parent().remove_child(player_instance)
			# Add player to new room at spawn position
			current_room_instance.add_child(player_instance)
			# Position player at entrance
			player_instance.position = Vector2(528, 455)  # Same as initial position in tscn
	
	# Add RoomManager script to the town scene
	current_room_manager = RoomManager.new()
	current_room_manager.enemy_scene = enemy_scene
	current_room_manager.consumable_scene = consumable_scene
	current_room_instance.add_child(current_room_manager)
	
	# Connect room completion signal
	current_room_manager.room_completed.connect(_on_room_completed)
	
	# Update player stats in UI
	if is_instance_valid(player_instance):
		_on_player_health_changed(player_instance.health, player_instance.max_health)

func spawn_boss_room():
	# Use the same base scene but configure for boss
	var room_scene = load("res://scenes/first_area/basic_level.tscn")
	current_room_instance = room_scene.instantiate()
	add_child(current_room_instance)
	
	# Move player to boss room
	if is_instance_valid(player_instance) and player_instance.get_parent():
		player_instance.get_parent().remove_child(player_instance)
		current_room_instance.add_child(player_instance)
		player_instance.position = Vector2(528, 455)  # Same as initial position
	
	# Add BossRoomManager
	current_room_manager = BossRoomManager.new()
	current_room_manager.boss_scene = boss_scene
	current_room_instance.add_child(current_room_manager)
	
	# Connect boss defeated signal
	current_room_manager.boss_defeated.connect(_on_boss_defeated)

func _on_room_completed():
	# Wait a moment before transitioning
	await get_tree().create_timer(1.0).timeout
	spawn_next_room()

func _on_boss_defeated():
	emit_signal("boss_defeated")
	# Show victory screen
	$UI/GameHUD.visible = false
	$UI/VictoryScreen.visible = true
	$UI/VictoryScreen/VBoxContainer/CompletionLabel.text = "You cleared " + str(room_count) + " rooms and defeated the first boss!"

func _on_player_health_changed(current_health, max_health):
	$UI/GameHUD/PlayerStats/HealthLabel.text = "Health: " + str(current_health) + "/" + str(max_health)

func _on_player_died():
	# Show game over screen
	$UI/GameHUD.visible = false
	$UI/GameOverScreen.visible = true
	$UI/GameOverScreen/VBoxContainer/RoomsReachedLabel.text = "Rooms reached: " + str(room_count)
	emit_signal("game_over")

func _on_restart_button_pressed():
	# Clear everything and restart
	if current_room_instance:
		current_room_instance.queue_free()
		current_room_instance = null
		current_room_manager = null
	
	player_instance = null
	start_game()

func _on_continue_button_pressed():
	# Continue after boss (would go to next area)
	$UI/VictoryScreen.visible = false
	$UI/GameHUD.visible = true
	# Here you would transition to the next area
	# For now, just restart
	_on_restart_button_pressed()

func _on_main_menu_button_pressed():
	# Return to main menu
	# You'll need to implement this based on your game structure
	var main_menu_scene = load("res://scenes/main_menu.tscn")
	get_tree().change_scene_to_packed(main_menu_scene)
