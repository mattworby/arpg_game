class_name PlayerDataHandler
extends Node

signal health_changed(current_health, calculated_max_health)
signal mana_changed(current_mana, max_mana)
signal character_loaded(slot_index)

signal strength_changed
signal dexterity_changed
signal wisdom_changed

const MAX_SLOTS = 3

# Player Stats - Represent the *currently loaded* character
var current_health: float = 0
var base_health: float = 0
var current_mana: float = 0
var base_mana: float = 0
var strength: float = 0
var dexterity: float = 0
var wisdom: float = 0
var character_name: String = "Adventurer"
var character_class: String = ""

var calculated_max_health: float = 1
var calculated_max_mana: float = 1

var current_slot_index: int = -1

const SAVE_DIR = "user://saves/"
const SAVE_BASE_FILENAME = "player_save_slot_"
const SAVE_EXTENSION = ".cfg"
const SAVE_SECTION = "PlayerData"

# --- _ready() remains the same ---
func _ready():
	DirAccess.make_dir_absolute(SAVE_DIR)
	if get_tree():
		# get_tree().tree_exiting.connect(Callable(self, "save_current_character_data"))
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

# --- NEW: Get Basic Info Without Full Load ---
func get_slot_info(slot_index: int) -> Dictionary:
	var path = _get_save_path(slot_index)
	if path.is_empty() or not FileAccess.file_exists(path):
		return {} # Return empty dict if no save exists

	var config = ConfigFile.new()
	var err = config.load(path)

	if err == OK:
		# Load only the necessary info
		var info = {
			"name": config.get_value(SAVE_SECTION, "character_name", "Unknown"),
			"class": config.get_value(SAVE_SECTION, "character_class", "Unknown"),
			# Add level later if needed: "level": config.get_value(SAVE_SECTION, "level", 1)
		}
		return info
	else:
		printerr("Error loading basic info from '", path, "': ", error_string(err))
		return {} # Return empty on load error


func load_character_data(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		printerr("Attempted to load invalid slot index: ", slot_index)
		return false

	var path = _get_save_path(slot_index)
	var config = ConfigFile.new()
	# Use does_save_exist first to handle the 'new game' case cleanly
	if not does_save_exist(slot_index):
		printerr("No save file found at '", path, "' to load for slot ", slot_index)
		# Resetting might be handled by the creation screen flow now
		# reset_to_defaults()
		# current_slot_index = -1
		return false

	var err = config.load(path)
	if err == OK:
		print("Loading character data from:", path)
		base_health = config.get_value(SAVE_SECTION, "base_health", 0)
		base_mana = config.get_value(SAVE_SECTION, "base_mana", 0)
		strength = config.get_value(SAVE_SECTION, "strength", 0)
		dexterity = config.get_value(SAVE_SECTION, "dexterity", 0)
		wisdom = config.get_value(SAVE_SECTION, "wisdom", 0)
		# --- Load Name and Class ---
		character_name = config.get_value(SAVE_SECTION, "character_name", "Adventurer")
		character_class = config.get_value(SAVE_SECTION, "character_class", "")
		# --------------------------

		current_health = clamp(current_health, 0, base_health)
		current_mana = clamp(current_mana, 0, base_mana)
		current_slot_index = slot_index
		print("Loaded data for slot ", slot_index, ": Name=", character_name, " (", character_class, ") HP=", current_health, "/", base_health, ", MP=", current_mana, "/", base_mana)

		emit_signal("health_changed", current_health, base_health)
		emit_signal("mana_changed", current_mana, base_mana)
		emit_signal("character_loaded", current_slot_index)
		return true
	else:
		printerr("Failed to load character data from '", path, "': ", error_string(err))
		reset_to_defaults() # Fallback to defaults on error
		current_slot_index = -1
		return false


func save_current_character_data():
	if current_slot_index < 0 or current_slot_index >= MAX_SLOTS:
		print("No valid character loaded (slot ", current_slot_index, "), skipping save.")
		return

	var path = _get_save_path(current_slot_index)
	print("Saving character data for slot ", current_slot_index, " to:", path)
	var config = ConfigFile.new()

	config.set_value(SAVE_SECTION, "base_health", base_health)
	config.set_value(SAVE_SECTION, "base_mana", base_mana)
	config.set_value(SAVE_SECTION, "strength", strength)
	config.set_value(SAVE_SECTION, "dexterity", dexterity)
	config.set_value(SAVE_SECTION, "wisdom", wisdom)
	# --- Save Name and Class ---
	config.set_value(SAVE_SECTION, "character_name", character_name)
	config.set_value(SAVE_SECTION, "character_class", character_class)
	# --------------------------

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
	# --- Reset Name and Class to Defaults ---
	character_name = "Adventurer" # Default name for new char
	character_class = ""
	# ----------------------------------------
	# Don't reset current_slot_index here, it's managed by the calling context
	emit_signal("health_changed", current_health, base_health)
	emit_signal("mana_changed", current_mana, base_mana)


func delete_character_data(slot_index: int) -> bool:
	# --- Delete function remains the same ---
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


# --- Data Access and Modification ---
# (getters remain the same)
func get_health() -> float: return current_health
func get_base_health() -> float: return base_health
func get_calculated_max_heath() -> float: return calculated_max_health
func get_mana() -> float: return current_mana
func get_base_mana() -> float: return base_mana
func get_calculated_max_mana() -> float: return calculated_max_mana
func get_strength() -> float: return strength
func get_wisdom() -> float: return wisdom
func get_dexterity() -> float: return dexterity
func get_character_name() -> String: return character_name # Getter for name
func get_character_class() -> String: return character_class # Getter for class

# Setters
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

# --- NEW Setters for Name and Class ---
func set_character_name(new_name: String):
	if new_name.strip_edges().is_empty():
		printerr("Attempted to set empty character name.")
		return # Or set to a default? "Adventurer"?
	character_name = new_name.strip_edges()
	print("Character name set to: ", character_name)

func set_character_class(new_class: String):
	# Optional: Validate against a list of known classes?
	character_class = new_class
	print("Character class set to: ", character_class)

func set_strength(value: float):
	# Optional: Validate against a list of known classes?
	strength = value
	print("Strength set to: ", character_class)
	emit_signal("strength_changed")
	
func set_dexterity(value: float):
	# Optional: Validate against a list of known classes?
	dexterity = value
	print("Dexterity set to: ", character_class)
	emit_signal("dexterity_changed")
	
func set_wisdom(value: float):
	# Optional: Validate against a list of known classes?
	wisdom = value
	print("Wisdom set to: ", character_class)
	emit_signal("wisdom_changed")

func set_current_slot(slot_index: int):
	if slot_index < -1 or slot_index >= MAX_SLOTS:
		printerr("Attempted to set invalid slot index: ", slot_index)
		return
	current_slot_index = slot_index
	print("Current character slot set to: ", current_slot_index)
