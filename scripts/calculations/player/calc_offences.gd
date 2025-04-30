extends Node

func _ready():
	call_deferred("_initialize_connections")

func _initialize_connections():
	PlayerData.character_loaded.connect(_on_character_loaded)
	PlayerData.attack_damage_changed.connect(calculate_attack_damage)
	PlayerData.melee_damage_changed.connect(calculate_melee_damage)
	PlayerData.projectile_damage_changed.connect(calculate_projectile_damage)
	PlayerData.spell_damage_changed.connect(calculate_spell_damage)
	PlayerData.attack_speed_changed.connect(calculate_attack_speed)
	PlayerData.physical_damage_changed.connect(calculate_physical_damage)
	PlayerData.fire_damage_changed.connect(calculate_fire_damage)
	PlayerData.cold_damage_changed.connect(calculate_cold_damage)
	PlayerData.lightning_damage_changed.connect(calculate_lightning_damage)
	PlayerData.poison_damage_changed.connect(calculate_poison_damage)
	PlayerData.critical_chance_changed.connect(calculate_critical_chance)
	PlayerData.critical_damage_changed.connect(calculate_critical_damage)
	
func _on_character_loaded(slot_index: int):
	if slot_index != -1:
		print("CharacterOffenceCalculator: Received character_loaded signal for slot ", slot_index)
		calculate_all_offences()
	else:
		print("CharacterOffenceCalculator: Received character_loaded signal for invalid slot (-1).")

func calculate_all_offences():
	calculate_attack_damage()
	calculate_melee_damage()
	calculate_projectile_damage()
	calculate_spell_damage()
	calculate_attack_speed()
	calculate_physical_damage()
	calculate_fire_damage()
	calculate_cold_damage()
	calculate_lightning_damage()
	calculate_poison_damage()
	calculate_critical_chance()
	calculate_critical_damage()

func calculate_attack_damage():
	return GlobalOffences.get_inc_attack_damage() * GlobalOffences.get_more_attack_damage()

func calculate_melee_damage():
	return GlobalOffences.get_inc_melee_damage() * GlobalOffences.get_more_melee_damage()
	
func calculate_projectile_damage():
	return GlobalOffences.get_inc_projectile_damage() * GlobalOffences.get_more_projectile_damage()
	
func calculate_spell_damage():
	return GlobalOffences.get_inc_melee_damage() * GlobalOffences.get_more_melee_damage()
	
func calculate_attack_speed():
	return GlobalOffences.get_inc_attack_speed() * GlobalOffences.get_more_attack_speed()

	
func calculate_physical_damage():
	return GlobalOffences.get_inc_physical_damage() * GlobalOffences.get_more_physical_damage()
	
func calculate_fire_damage():
	return GlobalOffences.get_inc_fire_damage() * GlobalOffences.get_more_fire_damage()
	
func calculate_cold_damage():
	return GlobalOffences.get_inc_cold_damage() * GlobalOffences.get_more_cold_damage()
	
func calculate_lightning_damage():
	return GlobalOffences.get_inc_lightning_damage() * GlobalOffences.get_more_lightning_damage()
	
func calculate_poison_damage():
	return GlobalOffences.get_inc_poison_damage() * GlobalOffences.get_more_poison_damage()
	
func calculate_critical_chance():
	return GlobalOffences.get_inc_critical_chance() * GlobalOffences.get_more_critical_chance()
		
func calculate_critical_damage():
	return GlobalOffences.get_inc_critical_damage() * GlobalOffences.get_more_critical_damage()
