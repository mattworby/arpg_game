extends Node

@export var enemy_scene: PackedScene
@export var player_scene: PackedScene = preload("res://scenes/player/player.tscn")

@onready var player_spawn_point = $SpawnPositions/PlayerSpawnPoint
@onready var dropped_items_container: Node2D = $DroppedItemsContainer 
@onready var room_generator_node: RoomGenerator = $RoomGeneratorInstance 

var player_instance = null
var player_body: CharacterBody2D = null

func _ready():
	if not is_instance_valid(room_generator_node):
		push_error("ForestLevel: RoomGeneratorInstance node not found!")
		return
	room_generator_node.enemy_scene = enemy_scene

	if not is_instance_valid(dropped_items_container):
		push_warning("ForestLevel: DroppedItemsContainer node not found! Creating one.")
		dropped_items_container = Node2D.new()
		dropped_items_container.name = "DroppedItemsContainer"
		add_child(dropped_items_container)


	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player_instance = players[0]
		if player_instance is CharacterBody2D: player_body = player_instance
		else: player_body = player_instance.find_child("*CharacterBody2D*", true, false)

		if is_instance_valid(player_body) and is_instance_valid(player_spawn_point):
			player_body.global_position = player_spawn_point.global_position
		elif not is_instance_valid(player_body):
			push_error("ForestLevel: Existing player found but has no CharacterBody2D.")
			return
	else:
		if player_scene:
			player_instance = player_scene.instantiate()
			add_child(player_instance)
			if player_instance is CharacterBody2D: player_body = player_instance
			else: player_body = player_instance.find_child("*CharacterBody2D*", true, false)

			if is_instance_valid(player_body) and is_instance_valid(player_spawn_point):
				player_body.global_position = player_spawn_point.global_position
			elif not is_instance_valid(player_body):
				push_error("ForestLevel: Instantiated player has no CharacterBody2D.")
				player_instance.queue_free()
				return
		else:
			push_error("ForestLevel: Player scene not set, cannot create player.")
			return

	GameManager.register_level(self)
	GameManager.register_player(player_instance, player_body)

	generate_next_room() 

func get_dropped_items_container() -> Node2D:
	return dropped_items_container

func generate_next_room():
	print("ForestLevel: Instructed to generate next room (Room: %d)" % GameManager.current_room)
	clear_room_visuals()

	if is_instance_valid(room_generator_node) and is_instance_valid(player_body):
		room_generator_node.room_size = get_viewport().get_visible_rect().size
		room_generator_node.generate_room(player_body)
	else:
		push_error("ForestLevel: Cannot generate room - RoomGenerator or PlayerBody invalid.")

func clear_room_visuals():
	if is_instance_valid(dropped_items_container):
		for item_label in dropped_items_container.get_children():
			item_label.queue_free()

func _on_restart_button_pressed():
	GameManager.restart_game()

func _on_main_menu_button_pressed():
	GameManager.go_to_main_menu()

func _exit_tree():
	if GameManager.current_level_instance == self:
		GameManager.unregister_level()
	pass 
