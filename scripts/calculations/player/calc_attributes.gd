extends Node

func _ready():
	call_deferred("_initialize_connections")

func _initialize_connections():

	PlayerData.character_loaded.connect(_on_character_loaded)
	PlayerData.strength_changed.connect(calculate_max_health)
	PlayerData.dexterity_changed.connect(calculate_evasion_rating)
	PlayerData.wisdom_changed.connect(calculate_max_mana)

func _on_character_loaded(slot_index: int):
	if slot_index != -1:
		print("CharacterStatCalculator: Received character_loaded signal for slot ", slot_index)
		calculate_all_stats()
	else:
		print("CharacterStatCalculator: Received character_loaded signal for invalid slot (-1).")

func calculate_all_stats():
	calculate_max_health()
	calculate_max_mana()
	calculate_evasion_rating()

func calculate_max_health():
	var base_hp = PlayerData.get_base_health()
	var str_stat = PlayerData.get_strength()
	var calculated_max_hp = base_hp + (str_stat * 2.0)
	
	calculated_max_hp = max(1.0, calculated_max_hp)
	PlayerData.set_calculated_max_health(calculated_max_hp)

func calculate_max_mana():
	var base_mp = PlayerData.get_base_mana()
	var wis_stat = PlayerData.get_wisdom()
	var calculated_max_mp = base_mp + (wis_stat * 5)
	
	calculated_max_mp = max(1.0, calculated_max_mp)
	PlayerData.set_calculated_max_mana(calculated_max_mp)
	
func calculate_evasion_rating():
	var dex_stat = PlayerData.get_dexterity()
	var evasion = dex_stat * 20
	
	PlayerData.set_evasion(evasion)
