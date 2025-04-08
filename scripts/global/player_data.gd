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

# player defences
signal evasion_changed

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

var evasion: float = 0
var health_regen_rate: float = 0
var mana_regen_rate: float = 0

var character_name: String = "Adventurer"
var character_class: String = ""

var calculated_max_health: float = 1
var calculated_max_mana: float = 1

var current_slot_index: int = -1

const SAVE_DIR = "user://saves/"
const SAVE_BASE_FILENAME = "player_save_slot_"
const SAVE_EXTENSION = ".cfg"
const SAVE_SECTION = "PlayerData"
const STATS_SECTION = "Stats"

func _ready():
	DirAccess.make_dir_absolute(SAVE_DIR)
	if get_tree():
		print("PlayerData ready. Connected save_current_character_data to tree_exiting signal.")
	else:
		printerr("PlayerData Error: Could not get SceneTree in _ready.")


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
		current_slot_index = slot_index
		print("Loaded data for slot ", slot_index, ": Name=", character_name, " (", character_class, ") HP=", current_health, "/", base_health, ", MP=", current_mana, "/", base_mana)

		emit_signal("health_changed", current_health, base_health)
		emit_signal("mana_changed", current_mana, base_mana)
		emit_signal("character_loaded", current_slot_index)
		emit_signal("level_changed", level)
		return true
	else:
		printerr("Failed to load character data from '", path, "': ", error_string(err))
		reset_to_defaults()
		current_slot_index = -1
		return false


func save_current_character_data():
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
func get_evasion() -> float: return evasion

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
		var exp_over = experience - exp_needed_for_next
		print("LEVEL UP! Reached Level ", level + 1)
		set_level(level + 1)
		exp_needed_for_next = get_total_experience_for_level(level + 1)
	emit_experience_signal()

func set_strength(value: float):
	strength = value
	print("Strength set to: ", character_class)
	emit_signal("strength_changed")
	
func set_dexterity(value: float):
	dexterity = value
	print("Dexterity set to: ", character_class)
	emit_signal("dexterity_changed")
	
func set_wisdom(value: float):
	wisdom = value
	print("Wisdom set to: ", character_class)
	emit_signal("wisdom_changed")

func set_evasion(value: float):
	evasion = value
	print("Wisdom set to: ", character_class)
	emit_signal("wisdom_changed")

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
