# res://scripts/global/PlayerData.gd
extends Node

signal health_changed(current_health, max_health)
signal mana_changed(current_mana, max_mana)
signal character_loaded(slot_index)

const DEFAULT_MAX_HEALTH = 100.0
const DEFAULT_MAX_MANA = 100.0
const DEFAULT_CLASS = "Fighter" # Default class if none specified
const MAX_SLOTS = 3

# Player Stats - Represent the *currently loaded* character
var current_health: float = DEFAULT_MAX_HEALTH
var max_health: float = DEFAULT_MAX_HEALTH
var current_mana: float = DEFAULT_MAX_MANA
var max_mana: float = DEFAULT_MAX_MANA
var character_name: String = "Adventurer"
var character_class: String = DEFAULT_CLASS # Added character class

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
		max_health = config.get_value(SAVE_SECTION, "max_health", DEFAULT_MAX_HEALTH)
		current_health = config.get_value(SAVE_SECTION, "current_health", max_health)
		max_mana = config.get_value(SAVE_SECTION, "max_mana", DEFAULT_MAX_MANA)
		current_mana = config.get_value(SAVE_SECTION, "current_mana", max_mana)
		# --- Load Name and Class ---
		character_name = config.get_value(SAVE_SECTION, "character_name", "Adventurer")
		character_class = config.get_value(SAVE_SECTION, "character_class", DEFAULT_CLASS)
		# --------------------------

		current_health = clamp(current_health, 0, max_health)
		current_mana = clamp(current_mana, 0, max_mana)
		current_slot_index = slot_index
		print("Loaded data for slot ", slot_index, ": Name=", character_name, " (", character_class, ") HP=", current_health, "/", max_health, ", MP=", current_mana, "/", max_mana)

		emit_signal("health_changed", current_health, max_health)
		emit_signal("mana_changed", current_mana, max_mana)
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

	config.set_value(SAVE_SECTION, "max_health", max_health)
	config.set_value(SAVE_SECTION, "current_health", current_health)
	config.set_value(SAVE_SECTION, "max_mana", max_mana)
	config.set_value(SAVE_SECTION, "current_mana", current_mana)
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
	max_health = DEFAULT_MAX_HEALTH
	current_health = max_health
	max_mana = DEFAULT_MAX_MANA
	current_mana = max_mana
	# --- Reset Name and Class to Defaults ---
	character_name = "Adventurer" # Default name for new char
	character_class = DEFAULT_CLASS
	# ----------------------------------------
	# Don't reset current_slot_index here, it's managed by the calling context
	emit_signal("health_changed", current_health, max_health)
	emit_signal("mana_changed", current_mana, max_mana)


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
			emit_signal("health_changed", current_health, max_health)
			emit_signal("mana_changed", current_mana, max_mana)
			emit_signal("character_loaded", current_slot_index)
		return true
	else:
		printerr("Error deleting character data file '", path, "': ", error_string(err))
		return false


# --- Data Access and Modification ---
# (getters remain the same)
func get_health() -> float: return current_health
func get_max_health() -> float: return max_health
func get_mana() -> float: return current_mana
func get_max_mana() -> float: return max_mana
func get_character_name() -> String: return character_name # Getter for name
func get_character_class() -> String: return character_class # Getter for class

# Setters
func set_health(value: float):
	var previous_health = current_health
	current_health = clamp(value, 0, max_health)
	if current_health != previous_health: emit_signal("health_changed", current_health, max_health)

func set_max_health(value: float):
	var previous_max = max_health
	var previous_health = current_health # Store health before potential clamp
	max_health = max(1.0, value)
	current_health = min(current_health, max_health)
	if max_health != previous_max or current_health != previous_health: # Check against original health
		emit_signal("health_changed", current_health, max_health)

func set_mana(value: float):
	var previous_mana = current_mana
	current_mana = clamp(value, 0, max_mana)
	if current_mana != previous_mana: emit_signal("mana_changed", current_mana, max_mana)

func set_max_mana(value: float):
	var previous_max = max_mana
	var previous_mana = current_mana # Store mana before potential clamp
	max_mana = max(1.0, value)
	current_mana = min(current_mana, max_mana)
	if max_mana != previous_max or current_mana != previous_mana: # Check against original mana
		emit_signal("mana_changed", current_mana, max_mana)

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
# ------------------------------------

func set_current_slot(slot_index: int):
	if slot_index < -1 or slot_index >= MAX_SLOTS:
		printerr("Attempted to set invalid slot index: ", slot_index)
		return
	current_slot_index = slot_index
	print("Current character slot set to: ", current_slot_index)
