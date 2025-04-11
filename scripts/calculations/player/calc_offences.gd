extends Node

func _ready():
	call_deferred("_initialize_connections")

func _initialize_connections():
	PlayerData.character_loaded.connect(_on_character_loaded)
	PlayerData.evasion_rating_changed.connect(calculate_physical_damage)

func _on_character_loaded(slot_index: int):
	if slot_index != -1:
		print("CharacterStatCalculator: Received character_loaded signal for slot ", slot_index)
		calculate_all_damage()
	else:
		print("CharacterStatCalculator: Received character_loaded signal for invalid slot (-1).")

func calculate_all_damage():
	calculate_physical_damage()

func calculate_attack_damage():
	print("test")
	
func calculate_melee_damage():
	print("test")
	
func calculate_spell_damage():
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

func calculate_increased():
	print("test")
	
func calculate_more():
	print("test")
	
func calculate_critical_strike_change():
	print("test")
	
func calculate_critical_strike_mult():
	print("test")
