extends Control

@onready var health_orb = $HealthOrb/HealthFill/HealthProgress
@onready var mana_orb = $ManaOrb/ManaFill/ManaProgress
@onready var xp_progress: TextureProgressBar = $XPBarContainer/XPProgress

func _ready():
	add_to_group("ui")

	await get_tree().process_frame

	if PlayerData: 
		PlayerData.health_changed.connect(_on_global_health_changed)
		PlayerData.mana_changed.connect(_on_global_mana_changed)
		PlayerData.experience_changed.connect(_on_global_experience_changed)

		_on_global_health_changed(PlayerData.get_health(), PlayerData.get_calculated_max_heath())
		_on_global_mana_changed(PlayerData.get_mana(), PlayerData.get_calculated_max_mana())
		
		var initial_exp_progress = PlayerData.get_experience_progress_in_current_level()
		var initial_exp_needed_bracket = PlayerData.get_experience_needed_for_next_level_bracket()
		_update_xp_bar(initial_exp_progress, initial_exp_needed_bracket)
	else:
		printerr("HealthManaUI Error: PlayerData Autoload not found!")
		if xp_progress: xp_progress.value = 0

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

func _on_global_experience_changed(current_total_exp: float, exp_for_next_level_total: float, exp_progress_in_level: float):
	var exp_needed_bracket = PlayerData.get_experience_needed_for_next_level_bracket()
	_update_xp_bar(exp_progress_in_level, exp_needed_bracket)

func _update_xp_bar(progress: float, needed: float):
	if needed > 0:
		var percentage = progress / needed
		xp_progress.value = clamp(percentage * 100.0, 0.0, 100.0)
	else:
		xp_progress.value = 100.0
