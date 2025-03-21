extends Camera2D

# Reference to the player character
@export var target_node_path: NodePath
@onready var target = get_node(target_node_path) if not target_node_path.is_empty() else null

# UI reference
@onready var health_mana_ui = $HealthManaUI

func _ready():
	# Find player if not set via export
	if target == null:
		# Try to find player in parent nodes first
		var parent = get_parent()
		while parent and not target:
			if parent.is_in_group("player"):
				target = parent
				break
			parent = parent.get_parent()
		
		# If still not found, look for any player in the scene
		if target == null:
			var players = get_tree().get_nodes_in_group("player")
			if players.size() > 0:
				target = players[0]
	
	# Connect to player health/mana signals if found
	if target and target.has_signal("health_changed") and health_mana_ui:
		target.health_changed.connect(_on_player_health_changed)
		target.mana_changed.connect(_on_player_mana_changed)
		
		# Initialize UI with player values
		health_mana_ui.set_max_health(target.max_health)
		health_mana_ui.set_health(target.health)
		health_mana_ui.set_max_mana(target.max_mana)
		health_mana_ui.set_mana(target.mana)

func _process(delta):
	if target:
		# Update camera position to follow target
		global_position = target.global_position

# Signal handlers
func _on_player_health_changed(current_health, max_health):
	if health_mana_ui:
		health_mana_ui.set_max_health(max_health)
		health_mana_ui.set_health(current_health)

func _on_player_mana_changed(current_mana, max_mana):
	if health_mana_ui:
		health_mana_ui.set_max_mana(max_mana)
		health_mana_ui.set_mana(current_mana)
