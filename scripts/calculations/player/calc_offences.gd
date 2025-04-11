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
		print("CharacterDefenceCalculator: Received character_loaded signal for slot ", slot_index)
		calculate_all_offences()
	else:
		print("CharacterDefenceCalculator: Received character_loaded signal for invalid slot (-1).")

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
	print("test")

func calculate_melee_damage():
	print("test")
	
func calculate_projectile_damage():
	print("test")
	
func calculate_spell_damage():
	print("test")
	
func calculate_attack_speed():
	print("test")
	
func calculate_physical_damage():
	print("test")
	
func calculate_fire_damage():
	print("test")
	
func calculate_cold_damage():
	print("test")
	
func calculate_lightning_damage():
	print("test")
	
func calculate_poison_damage():
	print("test")
	
func calculate_critical_chance():
	print("test")
	
func calculate_critical_damage():
	print("test")
