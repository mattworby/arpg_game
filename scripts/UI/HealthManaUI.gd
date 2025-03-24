extends Control

# References to UI elements
@onready var health_orb = $HealthOrb/HealthFill/HealthProgress
@onready var mana_orb = $ManaOrb/ManaFill/ManaProgress

# Current values
var current_health: float = 100.0
var max_health: float = 100.0
var current_mana: float = 100.0
var max_mana: float = 100.0

func _ready():
	add_to_group("ui")
	
	# Wait one frame to ensure the scene is fully loaded
	await get_tree().process_frame
	
	# Try to find the player by looking for the CharacterBody2D with player.gd script
	var player = find_player_node()
	
	if player:
		# Connect to player health/mana signals
		player.health_changed.connect(_on_player_health_changed)
		player.mana_changed.connect(_on_player_mana_changed)
		
		# Initialize UI with player values
		set_max_health(player.max_health)
		set_health(player.health)
		set_max_mana(player.max_mana)
		set_mana(player.mana)
	
	update_ui()

func find_player_node():
	# Looking for the CharacterBody2D that has the player script
	var character_bodies = get_tree().get_nodes_in_group("player")
	if character_bodies.size() > 0:
		return character_bodies[0]
		
	# If not found by group, try to find the CharacterBody2D directly
	var root = get_tree().root
	var player_node = root.find_child("CharacterBody2D", true, false)
	if player_node:
		return player_node
		
	return null

func set_health(value: float):
	current_health = clamp(value, 0, max_health)
	update_ui()

func set_max_health(value: float):
	max_health = max(1, value)
	current_health = min(current_health, max_health)
	update_ui()

func set_mana(value: float):
	current_mana = clamp(value, 0, max_mana)
	update_ui()

func set_max_mana(value: float):
	max_mana = max(1, value)
	current_mana = min(current_mana, max_mana)
	update_ui()

# Signal handlers moved from player_camera
func _on_player_health_changed(current_health, max_health):
	set_max_health(max_health)
	set_health(current_health)

func _on_player_mana_changed(current_mana, max_mana):
	set_max_mana(max_mana)
	set_mana(current_mana)

func update_ui():
	# Calculate fill percentages
	var health_percentage = current_health / max_health
	var mana_percentage = current_mana / max_mana
	
	health_orb.value = health_orb.max_value * health_percentage
	mana_orb.value = mana_orb.max_value * mana_percentage
