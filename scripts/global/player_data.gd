class_name PlayerDataHandler
extends Node

signal health_changed(current_health, calculated_max_health)
signal mana_changed(current_mana, max_mana)
signal character_loaded(slot_index)
signal level_changed(new_level)
signal experience_changed(current_exp, exp_to_next_level_total, exp_progress_in_level)

signal strength_changed
signal dexterity_changed
signal wisdom_changed

#player offenses
signal physical_damage_changed
signal fire_damage_changed
signal cold_damage_changed
signal lightning_damage_changed
signal poison_damage_changed

# player defences
signal evasion_rating_changed
signal evasion_changed
signal armour_rating_changed
signal block_changed

signal max_physical_resistance_changed
signal max_fire_resistance_changed
signal max_cold_resistance_changed
signal max_lightning_resistance_changed
signal max_poison_resistance_changed

signal physical_resistance_changed
signal fire_resistance_changed
signal cold_resistance_changed
signal lightning_resistance_changed
signal poison_resistance_changed

const MAX_SLOTS = 3
const MAX_LEVEL = 100
const EXP_BASE: float = 1031.0
const EXP_EXPONENT: float = 3.0

var level: int = 1
var experience: float = 0.0

var current_health: float = 0
var base_health: float = 0
var current_mana: float = 0
var base_mana: float = 0

var strength: float = 0
var dexterity: float = 0
var wisdom: float = 0

var physical_damage: float = 0
var fire_damage: float = 0
var cold_damage: float = 0
var lightning_damage: float = 0
var poison_damage: float = 0

var armour_rating: float = 0
var block: float = 0
var evasion: float = 0
var evasion_rating: float = 0

var max_physical_resistance: float = 0
var max_fire_resistance: float = 0
var max_cold_resistance: float = 0
var max_lightning_resistance: float = 0
var max_poison_resistance: float = 0

var physical_resistance: float = 0
var fire_resistance: float = 0
var cold_resistance: float = 0
var lightning_resistance: float = 0
var poison_resistance: float = 0

var calc_physical_resistance: float = 0
var calc_fire_resistance: float = 0
var calc_cold_resistance: float = 0
var calc_lightning_resistance: float = 0
var calc_poison_resistance: float = 0

var overcap_fire_resistance: float = 0
var overcap_cold_resistance: float = 0
var overcap_lightning_resistance: float = 0
var overcap_poison_resistance: float = 0

var health_regen_rate: float = 0
var mana_regen_rate: float = 0

var character_name: String = "Adventurer"
var character_class: String = ""

var calculated_max_health: float = 1
var calculated_max_mana: float = 1

var current_slot_index: int = -1
var _pending_inventory_load_data: Dictionary = {}

const SAVE_DIR = "user://saves/"
const SAVE_BASE_FILENAME = "player_save_slot_"
const SAVE_EXTENSION = ".cfg"
const SAVE_SECTION = "PlayerData"
const STATS_SECTION = "Stats"
const OFFENCE_SECTION = "Offences"
const DEFENCE_SECTION = "Defences"
const INVENTORY_SECTION = "Inventory"

@onready var global_inventory = get_node_or_null("/root/GlobalInventory")

func _ready():
	DirAccess.make_dir_absolute(SAVE_DIR)
	if get_tree():
		print("PlayerData ready. Connected save_current_character_data to tree_exiting signal.")
	else:
		printerr("PlayerData Error: Could not get SceneTree in _ready.")
		
	if not global_inventory:
		call_deferred("_check_and_connect_save") 
		
func _check_and_connect_save():
	if not global_inventory:
		global_inventory = get_node_or_null("/root/GlobalInventory")
	if not global_inventory:
		printerr("PlayerData Error: GlobalInventory node not found at /root/GlobalInventory! Inventory won't save.")

func _get_save_path(slot_index: int) -> String:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		printerr("Invalid slot index provided: ", slot_index)
		return ""
	return SAVE_DIR + SAVE_BASE_FILENAME + str(slot_index) + SAVE_EXTENSION

func does_save_exist(slot_index: int) -> bool:
	var path = _get_save_path(slot_index)
	if path.is_empty(): return false
	return FileAccess.file_exists(path)

func get_slot_info(slot_index: int) -> Dictionary:
	var path = _get_save_path(slot_index)
	if path.is_empty() or not FileAccess.file_exists(path):
		return {}

	var config = ConfigFile.new()
	var err = config.load(path)

	if err == OK:
		var info = {
			"name": config.get_value(SAVE_SECTION, "character_name", "Unknown"),
			"class": config.get_value(SAVE_SECTION, "character_class", "Unknown"),
			"level": config.get_value(STATS_SECTION, "level", 1)
		}
		return info
	else:
		printerr("Error loading basic info from '", path, "': ", error_string(err))
		return {}


func load_character_data(slot_index: int) -> bool:

	if slot_index < 0 or slot_index >= MAX_SLOTS:
		printerr("Attempted to load invalid slot index: ", slot_index)
		return false

	var path = _get_save_path(slot_index)
	var config = ConfigFile.new()
	if not does_save_exist(slot_index):
		printerr("No save file found at '", path, "' to load for slot ", slot_index)
		return false

	var err = config.load(path)
	if err == OK:
		print("Loading character data from:", path)

		_pending_inventory_load_data = {}
		
		character_name = config.get_value(SAVE_SECTION, "character_name", "Adventurer")
		character_class = config.get_value(SAVE_SECTION, "character_class", "")
		
		base_health = config.get_value(STATS_SECTION, "base_health", 0)
		base_mana = config.get_value(STATS_SECTION, "base_mana", 0)
		health_regen_rate = config.get_value(STATS_SECTION, "health_regen_rate", 0)
		mana_regen_rate = config.get_value(STATS_SECTION, "mana_regen_rate", 0)
		strength = config.get_value(STATS_SECTION, "strength", 0)
		dexterity = config.get_value(STATS_SECTION, "dexterity", 0)
		wisdom = config.get_value(STATS_SECTION, "wisdom", 0)
		
		level = config.get_value(STATS_SECTION, "level", 1)
		experience = config.get_value(STATS_SECTION, "experience", 0.0)
		
		level = clamp(level, 1, MAX_LEVEL)

		current_health = clamp(current_health, 0, base_health)
		current_mana = clamp(current_mana, 0, base_mana)
		
		var inventory_data_json = config.get_value(INVENTORY_SECTION, "data", "{}")
		var parse_result = JSON.parse_string(inventory_data_json)
		
		if parse_result != null and typeof(parse_result) == TYPE_DICTIONARY:
			print("  Storing pending inventory data...")
			_pending_inventory_load_data = parse_result
		elif inventory_data_json != "{}":
			printerr("  Failed to parse inventory data JSON from save file. Inventory will be empty.")
		else:
			print("  No inventory data found in save or data was empty.")
		
		current_slot_index = slot_index
		print("Loaded data for slot ", slot_index, ": Name=", character_name, " (", character_class, ") HP=", current_health, "/", base_health, ", MP=", current_mana, "/", base_mana)

		emit_signal("health_changed", current_health, base_health)
		emit_signal("mana_changed", current_mana, base_mana)
		emit_signal("character_loaded", current_slot_index)
		emit_signal("level_changed", level)
		emit_experience_signal()
		return true
	else:
		printerr("Failed to load character data from '", path, "': ", error_string(err))
		reset_to_defaults()
		current_slot_index = -1
		return false


func save_current_character_data():
	
	if not global_inventory:
		global_inventory = get_node_or_null("/root/GlobalInventory")
		if not global_inventory:
			printerr("PlayerData Save Error: GlobalInventory node not found! Cannot save inventory state.")
			
	if current_slot_index < 0 or current_slot_index >= MAX_SLOTS:
		print("No valid character loaded (slot ", current_slot_index, "), skipping save.")
		return

	var path = _get_save_path(current_slot_index)
	print("Saving character data for slot ", current_slot_index, " to:", path)
	var config = ConfigFile.new()
	
	config.set_value(SAVE_SECTION, "character_name", character_name)
	config.set_value(SAVE_SECTION, "character_class", character_class)

	config.set_value(STATS_SECTION, "base_health", base_health)
	config.set_value(STATS_SECTION, "base_mana", base_mana)
	config.set_value(STATS_SECTION, "health_regen_rate", health_regen_rate)
	config.set_value(STATS_SECTION, "mana_regen_rate", mana_regen_rate)
	config.set_value(STATS_SECTION, "strength", strength)
	config.set_value(STATS_SECTION, "dexterity", dexterity)
	config.set_value(STATS_SECTION, "wisdom", wisdom)
	
	config.set_value(STATS_SECTION, "level", level)
	config.set_value(STATS_SECTION, "experience", experience)
	
	var inventory_data_to_save = {}
	if global_inventory and global_inventory.has_method("get_inventory_save_data"):
		inventory_data_to_save = global_inventory.get_inventory_save_data()
		print("  Saving inventory state...")
	else:
		if global_inventory:
			printerr("  Could not get inventory state to save - GlobalInventory method unavailable.")
		inventory_data_to_save = {"grid": {}, "equipped": {}} # Save empty state
	
	var inventory_json_string = JSON.stringify(inventory_data_to_save, "\t")
	config.set_value(INVENTORY_SECTION, "data", inventory_json_string)
	
	if GlobalPassive and GlobalPassive.associated_slot_index == current_slot_index:
		var passives_json_string = JSON.stringify(GlobalPassive.player_passive_tree, "\t")
		config.set_value("Passives", "active", passives_json_string)
	else:
		print("PlayerData Save: Skipping passive save, GlobalPassive data not associated or missing.")

	var dir_path = path.get_base_dir()
	var err_dir = DirAccess.make_dir_recursive_absolute(dir_path)
	if err_dir != OK:
		printerr("Error creating save directory '", dir_path, "': ", error_string(err_dir))
		return

	var err_save = config.save(path)
	if err_save != OK:
		printerr("Error saving character data to '", path, "': ", error_string(err_save))
	else:
		print("Character data saved successfully for slot ", current_slot_index)


func reset_to_defaults():
	print("Resetting PlayerData to defaults.")
	base_health = 0
	current_health = base_health
	base_mana = 0
	current_mana = base_mana
	character_name = "Adventurer"
	character_class = ""
	level = 1
	experience = 0.0
	health_regen_rate = 0
	mana_regen_rate = 0
	
	_pending_inventory_load_data = {}
	
	emit_signal("health_changed", current_health, base_health)
	emit_signal("mana_changed", current_mana, base_mana)
	emit_signal("level_changed", level)


func delete_character_data(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= MAX_SLOTS: return false
	var path = _get_save_path(slot_index)
	if not FileAccess.file_exists(path): return false
	print("Attempting to delete character data file: ", path)
	var err = DirAccess.remove_absolute(path)
	if err == OK:
		print("Successfully deleted character data for slot ", slot_index)
		if current_slot_index == slot_index:
			print("Deleted the currently active character. Resetting PlayerData.")
			reset_to_defaults()
			current_slot_index = -1
			emit_signal("health_changed", current_health, base_health)
			emit_signal("mana_changed", current_mana, base_mana)
			emit_signal("character_loaded", current_slot_index)
		return true
	else:
		printerr("Error deleting character data file '", path, "': ", error_string(err))
		return false

func get_health() -> float: return current_health
func get_base_health() -> float: return base_health
func get_calculated_max_heath() -> float: return calculated_max_health
func get_mana() -> float: return current_mana
func get_base_mana() -> float: return base_mana
func get_calculated_max_mana() -> float: return calculated_max_mana

func get_health_regen_rate() -> float: return health_regen_rate
func get_mana_regen_rate() -> float: return mana_regen_rate

func get_physical_damage() -> float: return physical_damage
func get_fire_damage() -> float: return fire_damage
func get_cold_damage() -> float: return cold_damage
func get_lightning_damage() -> float: return lightning_damage
func get_poison_damage() -> float: return poison_damage

func get_armour_rating() -> float: return armour_rating
func get_evasion_rating() -> float: return evasion_rating
func get_evasion() -> float: return evasion
func get_block() -> float: return block

func get_physical_resistance() -> float: return physical_resistance
func get_fire_resistance() -> float: return fire_resistance
func get_cold_resistance() -> float: return cold_resistance
func get_lightning_resistance() -> float: return lightning_resistance
func get_poison_resistance() -> float: return poison_resistance
func get_calc_fire_resistance() -> float: return calc_fire_resistance
func get_calc_cold_resistance() -> float: return calc_cold_resistance
func get_calc_lightning_resistance() -> float: return calc_lightning_resistance
func get_calc_poison_resistance() -> float: return calc_poison_resistance
func get_max_physical_resistance() -> float: return max_physical_resistance
func get_max_fire_resistance() -> float: return max_fire_resistance
func get_max_cold_resistance() -> float: return max_cold_resistance
func get_max_lightning_resistance() -> float: return max_lightning_resistance
func get_max_poison_resistance() -> float: return max_poison_resistance
func get_overcap_fire_resistance() -> float: return overcap_fire_resistance
func get_overcap_cold_resistance() -> float: return overcap_cold_resistance
func get_overcap_lightning_resistance() -> float: return overcap_lightning_resistance
func get_overcap_poison_resistance() -> float: return overcap_poison_resistance

func get_strength() -> float: return strength
func get_wisdom() -> float: return wisdom
func get_dexterity() -> float: return dexterity

func get_character_name() -> String: return character_name
func get_character_class() -> String: return character_class
func get_level() -> int: return level
func get_experience() -> float: return experience
func get_total_passive_points() -> int: return max(0, level - 1)

func set_health(value: float):
	var previous_health = current_health
	current_health = clamp(value, 0, calculated_max_health)
	if current_health != previous_health: emit_signal("health_changed", current_health, calculated_max_health)

func set_base_health(value: float):
	var previous_max = base_health
	var previous_health = current_health
	base_health = max(1.0, value)
	current_health = min(current_health, base_health)
	if base_health != previous_max or current_health != previous_health:
		emit_signal("health_changed", current_health, base_health)

func set_calculated_max_health(value: float):
	var new_max = max(1.0, value)
	if calculated_max_health != new_max:
		var previous_max = calculated_max_health
		calculated_max_health = new_max
		print("Calculated max health updated to: ", calculated_max_health)
		
		if calculated_max_health != previous_max:
			set_health(calculated_max_health)
			emit_signal("health_changed", calculated_max_health, calculated_max_health)

func set_mana(value: float):
	var previous_mana = current_mana
	current_mana = clamp(value, 0, calculated_max_mana)
	if current_mana != previous_mana: emit_signal("mana_changed", current_mana, calculated_max_mana)

func set_base_mana(value: float):
	var previous_max = base_mana
	var previous_mana = current_mana
	base_mana = max(1.0, value)
	current_mana = min(current_mana, base_mana)
	if base_mana != previous_max or current_mana != previous_mana:
		emit_signal("mana_changed", current_mana, base_mana)
		
func set_calculated_max_mana(value: float):
	var new_max = max(1.0, value)
	if calculated_max_mana != new_max:
		var previous_max = calculated_max_mana
		calculated_max_mana = new_max
		print("Calculated max mana updated to: ", calculated_max_mana)
		
		if calculated_max_mana != previous_max:
			set_mana(calculated_max_mana)
			emit_signal("mana_changed", calculated_max_mana, calculated_max_mana)

func set_health_regen_rate(value: float):
	health_regen_rate = max(0.0, value)

func set_mana_regen_rate(value: float):
	mana_regen_rate = max(0.0, value)

func set_character_name(new_name: String):
	if new_name.strip_edges().is_empty():
		printerr("Attempted to set empty character name.")
		return
	character_name = new_name.strip_edges()
	print("Character name set to: ", character_name)

func set_character_class(new_class: String):
	character_class = new_class
	print("Character class set to: ", character_class)
	
func set_level(new_level: int):
	var old_level = level
	level = clamp(new_level, 1, MAX_LEVEL)
	if level != old_level:
		print("Level changed to: ", level)
		emit_signal("level_changed", level)
		emit_experience_signal()
		save_current_character_data()
		
func add_experience(amount: float):
	if level >= MAX_LEVEL or amount <= 0: return

	experience += amount
	print("Gained %s experience. Total: %s" % [str(amount).pad_decimals(1), str(experience).pad_decimals(1)])
	
	var exp_needed_for_next = get_total_experience_for_level(level + 1)
	
	while experience >= exp_needed_for_next and level < MAX_LEVEL:
		var _exp_over = experience - exp_needed_for_next
		print("LEVEL UP! Reached Level ", level + 1)
		set_level(level + 1)
		exp_needed_for_next = get_total_experience_for_level(level + 1)
	emit_experience_signal()

func set_strength(value: float):
	strength = value
	print("Strength set to: ", strength)
	emit_signal("strength_changed")
	
func set_dexterity(value: float):
	dexterity = value
	print("Dexterity set to: ", dexterity)
	emit_signal("dexterity_changed")
	
func set_wisdom(value: float):
	wisdom = value
	print("Wisdom set to: ", wisdom)
	emit_signal("wisdom_changed")
	
func set_armour_rating(value: float):
	evasion_rating = value
	print("armour rating set to: ", evasion_rating)
	emit_signal("armour_rating_changed")

func set_evasion(value: float):
	evasion = value
	print("evasion set to: ", evasion)
	emit_signal("evasion_changed")
	
func set_block(value: float):
	block = value
	print("block set to: ", block)
	emit_signal("block_changed")
	
func set_evasion_rating(value: float):
	evasion_rating = value
	print("evasion_rating set to: ", evasion_rating)
	emit_signal("evasion_rating_changed")

func set_physical_damage(value: float):
	physical_damage = value
	print("physical_damage set to: ", physical_damage)
	emit_signal("physical_damage_changed")
	
func set_fire_damage(value: float):
	fire_damage = value
	print("fire_damage set to: ", fire_damage)
	emit_signal("fire_damage_changed")

func set_cold_damage(value: float):
	cold_damage = value
	print("cold_damage set to: ", cold_damage)
	emit_signal("cold_damage_changed")

func set_lightning_damage(value: float):
	lightning_resistance = value
	print("lightning_resistance set to: ", lightning_resistance)
	emit_signal("lightning_damage_changed")
	
func set_poison_damage(value: float):
	poison_damage = value
	print("poison_damage set to: ", poison_damage)
	emit_signal("poison_damage_changed")
	
func set_fire_resistance(value: float):
	fire_resistance = value
	print("fire_resistance set to: ", fire_resistance)
	emit_signal("fire_resistance_changed")

func set_cold_resistance(value: float):
	cold_resistance = value
	print("cold_resistance set to: ", cold_resistance)
	emit_signal("cold_resistance_changed")

func set_lightning_resistance(value: float):
	lightning_resistance = value
	print("lightning_resistance set to: ", lightning_resistance)
	emit_signal("lightning_resistance_changed")
	
func set_poison_resistance(value: float):
	poison_resistance = value
	print("poison_resistance set to: ", poison_resistance)
	emit_signal("poison_resistance_changed")
	
func set_calc_fire_resistance(value: float):
	calc_fire_resistance = value
	print("calc_fire_resistance set to: ", calc_fire_resistance)

func set_calc_cold_resistance(value: float):
	calc_cold_resistance = value
	print("calc_cold_resistance set to: ", calc_cold_resistance)

func set_calc_lightning_resistance(value: float):
	calc_lightning_resistance = value
	print("calc_lightning_resistance set to: ", calc_lightning_resistance)
	
func set_calc_poison_resistance(value: float):
	calc_poison_resistance = value
	print("calc_poison_resistance set to: ", calc_poison_resistance)
	
func set_max_physical_resistance(value: float):
	max_physical_resistance = value
	print("max_physical_resistance set to: ", max_physical_resistance)
	emit_signal("max_physical_resistance_changed")
	
func set_max_fire_resistance(value: float):
	max_fire_resistance = value
	print("max_fire_resistance set to: ", max_fire_resistance)
	emit_signal("max_fire_resistance_changed")

func set_max_cold_resistance(value: float):
	max_cold_resistance = value
	print("max_cold_resistance set to: ", max_cold_resistance)
	emit_signal("max_cold_resistance_changed")

func set_max_lightning_resistance(value: float):
	max_lightning_resistance = value
	print("max_lightning_resistance set to: ", max_lightning_resistance)
	emit_signal("max_lightning_resistance_changed")

func set_max_poison_resistance(value: float):
	max_poison_resistance = value
	print("max_poison_resistance set to: ", max_poison_resistance)
	emit_signal("max_poison_resistance_changed")
	
func set_overcap_fire_resistance(value: float):
	overcap_fire_resistance = value
	print("overcap_fire_resistance set to: ", overcap_fire_resistance)

func set_overcap_cold_resistance(value: float):
	overcap_cold_resistance = value
	print("overcap_cold_resistance set to: ", overcap_cold_resistance)

func set_overcap_lightning_resistance(value: float):
	overcap_lightning_resistance = value
	print("overcap_lightning_resistance set to: ", overcap_lightning_resistance)
	
func set_overcap_poison_resistance(value: float):
	overcap_poison_resistance = value
	print("overcap_poison_resistance set to: ", overcap_poison_resistance)

func set_current_slot(slot_index: int):
	if slot_index < -1 or slot_index >= MAX_SLOTS:
		printerr("Attempted to set invalid slot index: ", slot_index)
		return
	current_slot_index = slot_index
	print("Current character slot set to: ", current_slot_index)
	
func get_total_experience_for_level(target_level: int) -> float:
	if target_level <= 1:
		return 0.0
	target_level = min(target_level, MAX_LEVEL + 1)
	return EXP_BASE * pow(float(target_level - 1), EXP_EXPONENT)
	
func get_experience_needed_for_next_level_bracket() -> float:
	if level >= MAX_LEVEL:
		return 0.0

	var exp_for_current_level = get_total_experience_for_level(level)
	var exp_for_next_level = get_total_experience_for_level(level + 1)
	return exp_for_next_level - exp_for_current_level
	
func get_experience_progress_in_current_level() -> float:
	var exp_needed_for_this_level_total = get_total_experience_for_level(level)
	return max(0.0, experience - exp_needed_for_this_level_total)

func emit_experience_signal():
	var exp_progress = get_experience_progress_in_current_level()
	var exp_needed_bracket = get_experience_needed_for_next_level_bracket()
	var total_for_current_level = get_total_experience_for_level(level) if level < MAX_LEVEL else experience

	emit_signal("experience_changed", experience, total_for_current_level + exp_needed_bracket, exp_progress)

func get_pending_inventory_data() -> Dictionary:
	"""Returns the inventory data loaded from file, waiting to be applied."""
	return _pending_inventory_load_data

func clear_pending_inventory_data():
	"""Clears the pending inventory data after it has been loaded by GlobalInventory."""
	print("PlayerData: Clearing pending inventory data.")
	_pending_inventory_load_data = {}
