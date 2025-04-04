extends Node

signal passive_tree_updated(current_passives)

var passive_tree_scene = preload("res://scenes/menus/passive_tree/passive_tree.tscn")
var passive_tree_instance = null
var player_passive_tree : Dictionary = {}
var associated_slot_index : int = -1

func _ready():
	# --- ADD THIS LINE ---
	process_mode = Node.PROCESS_MODE_ALWAYS
	# ---------------------

	if passive_tree_instance == null:
		passive_tree_instance = passive_tree_scene.instantiate()
		passive_tree_instance.visible = false
		if passive_tree_instance.is_connected("passive_tree_changed", _on_passive_tree_changed) == false:
			passive_tree_instance.passive_tree_changed.connect(_on_passive_tree_changed)

	# Connect to PlayerData signals only once
	if PlayerData.is_connected("character_loaded", _on_character_loaded) == false:
		PlayerData.character_loaded.connect(_on_character_loaded)


func _input(event):
	# Now this will run even when paused
	var current_scene = get_tree().get_current_scene()
	if current_scene == null or current_scene.name == "TitleScreen":
		return

	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_P:
			# Check if the tree instance exists before toggling
			if passive_tree_instance:
				toggle_passive_tree()
			else:
				printerr("GlobalPassive: Attempted to toggle null passive tree instance!")


func toggle_passive_tree():
	var player = get_tree().get_first_node_in_group("player")

	if passive_tree_instance == null:
		printerr("Passive tree instance is null!")
		return
	
	print(passive_tree_instance.is_inside_tree())

	if !passive_tree_instance.is_inside_tree():
		var ui_layer = get_tree().get_root().find_child("UI_Layer", true, false)
		if !ui_layer:
			print("Creating UI Layer")
			ui_layer = CanvasLayer.new()
			ui_layer.name = "UI_Layer"
			get_tree().get_root().add_child(ui_layer)
		ui_layer.add_child(passive_tree_instance)
		# Don't set visible here, toggle_passive_tree in the instance handles it
		get_tree().paused = true
		if player and player.has_method("lock_movement"): player.lock_movement()

	# Call the instance's toggle method AFTER potentially adding it to the tree
	# This method will now handle loading the correct layout based on PlayerData
	passive_tree_instance.toggle_passive_tree()

	if !passive_tree_instance.visible:
		get_tree().paused = false
		if player and player.has_method("unlock_movement"): player.unlock_movement()
	else:
		get_tree().paused = true
		if player and player.has_method("lock_movement"): player.lock_movement()

func _on_character_loaded(slot_index: int):
	print("GlobalPassive detected character load for slot: ", slot_index)
	if slot_index >= 0:
		load_passives_for_slot(slot_index)
		associated_slot_index = slot_index
	else:
		player_passive_tree = {}
		associated_slot_index = -1
		print("GlobalPassive cleared passive tree data.")
	emit_signal("passive_tree_updated", player_passive_tree)

func load_passives_for_slot(slot_index: int):
	player_passive_tree = {}
	associated_slot_index = -1

	var path = PlayerData._get_save_path(slot_index)
	if path.is_empty() or not FileAccess.file_exists(path):
		printerr("GlobalPassive: No save file found at '", path, "' to load passives for slot ", slot_index)
		var player_class = PlayerData.get_character_class()
		var class_lower = player_class.to_lower()
		var layout_path = passive_tree_instance.LAYOUT_SCRIPT_PATH_FORMAT % class_lower
		if ResourceLoader.exists(layout_path):
			player_passive_tree = {"start": true} 
		else:
			player_passive_tree = {}

		associated_slot_index = slot_index 
		print("GlobalPassive: Initialized default passives for slot ", slot_index, ": ", player_passive_tree)
		return

	var config = ConfigFile.new()
	var err = config.load(path)
	if err == OK:
		var passives_str = config.get_value("Passives", "active", "{}")
		var parsed_data = JSON.parse_string(passives_str) # Use JSON for robust dict saving

		if typeof(parsed_data) == TYPE_DICTIONARY:
			player_passive_tree = parsed_data
			associated_slot_index = slot_index
			print("GlobalPassive: Loaded passives for slot ", slot_index, ": ", player_passive_tree)
		else:
			printerr("GlobalPassive: Failed to parse passive data from '", path, "'. Found: ", passives_str)
			player_passive_tree = {"start": true} if ResourceLoader.exists(passive_tree_instance.LAYOUT_SCRIPT_PATH_FORMAT % PlayerData.get_character_class().to_lower()) else {}
			associated_slot_index = slot_index
	else:
		printerr("GlobalPassive: Failed to load save file '", path, "' for passives: ", error_string(err))
		player_passive_tree = {"start": true} if ResourceLoader.exists(passive_tree_instance.LAYOUT_SCRIPT_PATH_FORMAT % PlayerData.get_character_class().to_lower()) else {}
		associated_slot_index = slot_index

func save_passives_for_current_slot():
	if associated_slot_index < 0:
		print("GlobalPassive: No valid character slot associated, skipping passive save.")
		return

	var path = PlayerData._get_save_path(associated_slot_index)
	if path.is_empty(): return

	print("GlobalPassive: Saving passives for slot ", associated_slot_index, " to:", path)
	var config = ConfigFile.new()

	var err_load = config.load(path)
	if err_load != OK and err_load != ERR_FILE_NOT_FOUND:
		printerr("GlobalPassive: Error loading existing save file '", path, "' before saving passives: ", error_string(err_load))

		config = ConfigFile.new() 

	var passives_json_string = JSON.stringify(player_passive_tree, "\t")
	config.set_value("Passives", "active", passives_json_string)

	var dir_path = path.get_base_dir()
	var err_dir = DirAccess.make_dir_recursive_absolute(dir_path)
	if err_dir != OK:
		printerr("GlobalPassive: Error creating save directory '", dir_path, "': ", error_string(err_dir))
		return

	var err_save = config.save(path)
	if err_save != OK:
		printerr("GlobalPassive: Error saving passives to '", path, "': ", error_string(err_save))
	else:
		print("GlobalPassive: Passives saved successfully for slot ", associated_slot_index)

func _on_passive_tree_changed(data: Dictionary):
	print("GlobalPassive received passive tree change signal.")
	if associated_slot_index != PlayerData.current_slot_index:
		printerr("GlobalPassive: Mismatch between associated slot (%d) and PlayerData slot (%d). Aborting passive update." % [associated_slot_index, PlayerData.current_slot_index])
		_on_character_loaded(PlayerData.current_slot_index)
		return

	player_passive_tree = data 
	save_passives_for_current_slot()
	emit_signal("passive_tree_updated", player_passive_tree)
