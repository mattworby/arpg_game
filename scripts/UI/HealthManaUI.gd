extends Control

# References to UI elements
@onready var health_orb = $HealthOrb/HealthFill
@onready var mana_orb = $ManaOrb/ManaFill

# Current values
var current_health: float = 100.0
var max_health: float = 100.0
var current_mana: float = 100.0
var max_mana: float = 100.0

func _ready():
	add_to_group("ui")
	update_ui()

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

func update_ui():
	# Calculate fill percentages
	var health_percentage = current_health / max_health
	var mana_percentage = current_mana / max_mana
	
	# Update the orb fills
	health_orb.scale.y = health_percentage
	health_orb.position.y = health_orb.texture.get_height() * (1.0 - health_percentage) * 0.5
	
	mana_orb.scale.y = mana_percentage
	mana_orb.position.y = mana_orb.texture.get_height() * (1.0 - mana_percentage) * 0.5
