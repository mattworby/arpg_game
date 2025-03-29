# res://scenes/ui/HealthManaUI.gd (or wherever your UI script is)
extends Control

# References to UI elements
@onready var health_orb = $HealthOrb/HealthFill/HealthProgress
@onready var mana_orb = $ManaOrb/ManaFill/ManaProgress

func _ready():
	add_to_group("ui")

	# Wait one frame to ensure PlayerData has loaded and emitted initial signals (optional, but safer)
	await get_tree().process_frame

	# Connect to PlayerData signals
	# Ensure PlayerData autoload is configured correctly in Project Settings!
	if PlayerData: # Check if the Autoload exists
		PlayerData.health_changed.connect(_on_global_health_changed)
		PlayerData.mana_changed.connect(_on_global_mana_changed)

		# Initialize UI with current values from PlayerData
		# These handlers will call update_ui implicitly
		_on_global_health_changed(PlayerData.get_health(), PlayerData.get_max_health())
		_on_global_mana_changed(PlayerData.get_mana(), PlayerData.get_max_mana())
	else:
		printerr("HealthManaUI Error: PlayerData Autoload not found!")

# Renamed signal handlers to reflect connection to global PlayerData
func _on_global_health_changed(current_health: float, max_health: float):
	# Update the UI directly based on the data received from PlayerData
	if max_health > 0: # Prevent division by zero
		var health_percentage = current_health / max_health
		health_orb.value = health_orb.max_value * health_percentage
	else:
		health_orb.value = 0

func _on_global_mana_changed(current_mana: float, max_mana: float):
	# Update the UI directly based on the data received from PlayerData
	if max_mana > 0: # Prevent division by zero
		var mana_percentage = current_mana / max_mana
		mana_orb.value = mana_orb.max_value * mana_percentage
	else:
		mana_orb.value = 0