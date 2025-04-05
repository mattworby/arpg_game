extends Control

@onready var health_orb = $HealthOrb/HealthFill/HealthProgress
@onready var mana_orb = $ManaOrb/ManaFill/ManaProgress

func _ready():
	add_to_group("ui")

	await get_tree().process_frame

	if PlayerData: 
		PlayerData.health_changed.connect(_on_global_health_changed)
		PlayerData.mana_changed.connect(_on_global_mana_changed)

		_on_global_health_changed(PlayerData.get_health(), PlayerData.get_calculated_max_heath())
		_on_global_mana_changed(PlayerData.get_mana(), PlayerData.get_calculated_max_mana())
	else:
		printerr("HealthManaUI Error: PlayerData Autoload not found!")

func _on_global_health_changed(current_health: float, max_health: float):
	if max_health > 0:
		var health_percentage = current_health / max_health
		health_orb.value = health_orb.max_value * health_percentage
	else:
		health_orb.value = 0

func _on_global_mana_changed(current_mana: float, max_mana: float):
	if max_mana > 0: 
		var mana_percentage = current_mana / max_mana
		mana_orb.value = mana_orb.max_value * mana_percentage
	else:
		mana_orb.value = 0
