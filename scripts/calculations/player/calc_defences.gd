extends Node

func _ready():
	call_deferred("_initialize_connections")

func _initialize_connections():

	PlayerData.character_loaded.connect(_on_character_loaded)
	PlayerData.evasion_changed.connect(calculate_evasion)

func _on_character_loaded(slot_index: int):
	if slot_index != -1:
		print("CharacterStatCalculator: Received character_loaded signal for slot ", slot_index)
		calculate_all_stats()
	else:
		print("CharacterStatCalculator: Received character_loaded signal for invalid slot (-1).")

func calculate_all_stats():
	calculate_evasion()

func calculate_evasion():
	print("evasion")

func calculate_armour():
	print("armour")
	
func calculate_fire_resistance():
	print("fire res")
	
func calculate_cold_resistance():
	print("cold res")
	
func calculate_lightning_resistance():
	print("light res")
