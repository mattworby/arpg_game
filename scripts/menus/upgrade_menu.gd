extends Control

signal option_selected(upgrade_type)

var upgrade_types = [
	{
		"name": "Damage Up",
		"description": "Increase damage by 20%",
		"icon": preload("res://assets/icons/damage_up.png"),
		"effect": "damage"
	},
	{
		"name": "Health Up",
		"description": "Increase max health by 1",
		"icon": preload("res://assets/icons/health_up.png"),
		"effect": "health"
	},
	{
		"name": "Speed Up",
		"description": "Increase movement speed by 10%",
		"icon": preload("res://assets/icons/speed_up.png"),
		"effect": "speed"
	},
	{
		"name": "Range Up",
		"description": "Increase attack range by 15%",
		"icon": preload("res://assets/icons/range_up.png"),
		"effect": "range"
	},
	{
		"name": "Attack Speed Up",
		"description": "Increase attack speed by 15%",
		"icon": preload("res://assets/icons/attack_speed_up.png"),
		"effect": "attack_speed"
	},
	{
		"name": "Magic Find Up",
		"description": "Increase rare item drop chance by 5%",
		"icon": preload("res://assets/icons/magic_find_up.png"),
		"effect": "magic_find"
	}
]

var selected_upgrades = []
var rng = RandomNumberGenerator.new()

func _ready():
	# Hide menu initially
	visible = false
	
	# Connect button signals
	$OptionContainer/Option1.pressed.connect(func(): _on_option_pressed(0))
	$OptionContainer/Option2.pressed.connect(func(): _on_option_pressed(1))
	$OptionContainer/Option3.pressed.connect(func(): _on_option_pressed(2))
	
	# Initialize RNG
	rng.randomize()

func show_menu():
	# Select 3 random upgrades
	randomize_upgrades()
	
	# Update UI
	update_ui()
	
	# Show menu
	visible = true
	
	# Pause the game
	get_tree().paused = true

func randomize_upgrades():
	# Shuffle all upgrades
	upgrade_types.shuffle()
	
	# Take first 3
	selected_upgrades = upgrade_types.slice(0, 3)

func update_ui():
	for i in range(3):
		var option_button = get_node("OptionContainer/Option" + str(i+1))
		var container = option_button.get_node("VBoxContainer")
		var icon = container.get_node("Icon")
		var name_label = container.get_node("Name")
		var desc_label = container.get_node("Description")
		
		icon.texture = selected_upgrades[i].icon
		name_label.text = selected_upgrades[i].name
		desc_label.text = selected_upgrades[i].description

func _on_option_pressed(index):
	# Emit signal with selected upgrade effect
	emit_signal("option_selected", selected_upgrades[index].effect)
	
	# Resume game
	get_tree().paused = false
	
	# Hide menu
	visible = false

func _input(event):
	if visible and event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			# Allow cancelling with ESC (defaults to first option)
			_on_option_pressed(0)
