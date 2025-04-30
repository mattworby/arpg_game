extends Node

func _ready():
	call_deferred("_initialize_connections")

func _initialize_connections():
	GlobalInventory.equipment_changed.connect(_equipment_changed)
	
func _equipment_changed(slot_index: int):
	if slot_index != -1:
		print("CharacterEquipmentCalculator: Received character_loaded signal for slot ", slot_index)
		calculate_all_offences()
		calculate_all_defences()
	else:
		print("CharacterEquipmentCalculator: Received character_loaded signal for invalid slot (-1).")

func calculate_all_offences():
	calculate_poison_resistance()

func calculate_all_defences():
	calculate_poison_resistance()
	
func calculate_poison_resistance():
	print("test")
