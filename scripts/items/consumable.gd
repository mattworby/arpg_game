extends Node2D

signal consumed(upgrade_type)

func _ready():
	add_to_group("consumables")
	
	# Make it visually appealing with animation
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(1.1, 1.1), 0.5)
	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 1.0), 0.5)
	tween.set_loops()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		show_upgrade_menu()

func show_upgrade_menu():
	# Stop player movement
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)
	
	# Get upgrade menu from scene
	var upgrade_menu = $UpgradeMenu
	
	# Show upgrade menu
	upgrade_menu.show_menu()
	
	# Connect option selection
	if not upgrade_menu.is_connected("option_selected", _on_upgrade_selected):
		upgrade_menu.option_selected.connect(_on_upgrade_selected)

func _on_upgrade_selected(upgrade_type):
	# Re-enable player movement
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(true)
	
	# Apply upgrade to player
	apply_upgrade(upgrade_type)
	
	# Signal consumption and destroy self
	emit_signal("consumed", upgrade_type)
	queue_free()

func apply_upgrade(upgrade_type):
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
		
	match upgrade_type:
		"damage":
			player.damage *= 1.2
		"health":
			player.max_health += 1
			player.health += 1
		"speed":
			player.speed *= 1.1
		"range":
			player.attack_range *= 1.15
		"attack_speed":
			player.attack_cooldown *= 0.85
		"magic_find":
			player.magic_find += 5
