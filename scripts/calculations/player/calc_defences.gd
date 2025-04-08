extends Node

func _ready():
	call_deferred("_initialize_connections")

func _initialize_connections():
	PlayerData.character_loaded.connect(_on_character_loaded)
	PlayerData.evasion_rating_changed.connect(calculate_evasion)
	PlayerData.armour_rating_changed.connect(calculate_physical_resistance)
	PlayerData.fire_resistance_changed.connect(calculate_fire_resistance)
	PlayerData.cold_resistance_changed.connect(calculate_cold_resistance)
	PlayerData.lightning_resistance_changed.connect(calculate_lightning_resistance)
	
	PlayerData.max_physical_resistance_changed.connect(calculate_physical_resistance)
	PlayerData.max_fire_resistance_changed.connect(calculate_fire_resistance)
	PlayerData.max_cold_resistance_changed.connect(calculate_cold_resistance)
	PlayerData.max_lightning_resistance_changed.connect(calculate_lightning_resistance)

func _on_character_loaded(slot_index: int):
	if slot_index != -1:
		print("CharacterStatCalculator: Received character_loaded signal for slot ", slot_index)
		calculate_all_stats()
	else:
		print("CharacterStatCalculator: Received character_loaded signal for invalid slot (-1).")

func calculate_all_stats():
	calculate_evasion()
	calculate_physical_resistance()
	calculate_fire_resistance()
	calculate_cold_resistance()
	calculate_lightning_resistance()

func calculate_evasion():
	var evasion_rating = PlayerData.get_evasion_rating()
	var evasion = 0
	var cap = 100
	var normalize = 2105
	var max = 95
	
	if evasion_rating <= 0:
		return 0
		
	evasion = (cap * evasion_rating) / (normalize + evasion_rating)
	if (evasion >= max):
		PlayerData.set_evasion(max)
	else:
		PlayerData.set_evasion(evasion)

func calculate_physical_resistance():
	var max = PlayerData.get_max_physical_resistance()
	var armour_rating = PlayerData.get_armour_rating()
	var physical_resistance = 0
	var cap = 100
	var normalize = 2105
	
	if armour_rating <= 0:
		return 0
		
	physical_resistance = (cap * armour_rating) / (normalize + armour_rating)
	
	if (physical_resistance >= max):
		PlayerData.set_calc_physical_resistance(max)
		PlayerData.set_overcap_physical_resistance(physical_resistance)
	else:
		PlayerData.set_calc_physical_resistance(physical_resistance)
		PlayerData.set_overcap_physical_resistance(0)
	
func calculate_fire_resistance():
	var max = PlayerData.get_max_fire_resistance()
	var value = PlayerData.get_fire_resistance()
	if (value >= max):
		PlayerData.set_calc_fire_resistance(max)
		PlayerData.set_overcap_fire_resistance(value)
	else:
		PlayerData.set_calc_fire_resistance(value)
		PlayerData.set_overcap_fire_resistance(0)
	
func calculate_cold_resistance():
	var max = PlayerData.get_max_cold_resistance()
	var value = PlayerData.get_cold_resistance()
	if (value >= max):
		PlayerData.set_calc_cold_resistance(max)
		PlayerData.set_overcap_cold_resistance(value)
	else:
		PlayerData.set_calc_cold_resistance(value)
		PlayerData.set_overcap_cold_resistance(0)
	
func calculate_lightning_resistance():
	var max = PlayerData.get_max_lightning_resistance()
	var value = PlayerData.get_lightning_resistance()
	if (value >= max):
		PlayerData.set_calc_lightning_resistance(max)
		PlayerData.set_overcap_lightning_resistance(value)
	else:
		PlayerData.set_calc_lightning_resistance(value)
		PlayerData.set_overcap_lightning_resistance(0)
