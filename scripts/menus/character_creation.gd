extends Control

@onready var name_edit: LineEdit = $CenterContainer/NameInputContainer/NameEdit
@onready var class_grid: GridContainer = $CenterContainer/ClassGrid
@onready var start_button: Button = $BottomButtons/StartButton
@onready var back_button: Button = $BottomButtons/BackButton
@onready var status_label: Label = $StatusLabel

const CLASS_SCRIPT_LOAD = "res://scripts/classes/%s.gd"

var selected_class: String = ""
var class_buttons: Array[Button] = []
var current_class: Dictionary = {} 

func _ready():
	if not PlayerData:
		printerr("CharacterCreation Error: PlayerData Autoload not found!")
		get_tree().quit()
		return

	for button in class_grid.get_children():
		if button is Button:
			class_buttons.append(button)
			var char_class_name = button.text
			button.pressed.connect(_on_class_selected.bind(char_class_name, button))

	start_button.pressed.connect(_on_start_adventure_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	name_edit.text_changed.connect(_validate_input)
	name_edit.text_submitted.connect(_on_start_adventure_pressed)

	name_edit.grab_focus()

	_validate_input()


func _on_class_selected(char_class_name: String, pressed_button: Button):
	selected_class = char_class_name
	status_label.text = "Selected Class: " + selected_class
	print("Selected Class:", selected_class)

	for button in class_buttons:
		button.disabled = false
		button.set("theme_override_styles/normal", null)

	pressed_button.disabled = true 

	_validate_input()


func _validate_input(_new_text: String = ""):
	var name_valid = not name_edit.text.strip_edges().is_empty()
	var class_valid = not selected_class.is_empty()

	if name_valid and class_valid:
		start_button.disabled = false
		if not status_label.text.begins_with("Selected Class:"):
			status_label.text = ""
	else:
		start_button.disabled = true
		if not name_valid and not class_valid:
			status_label.text = "Please enter a name and select a class."
		elif not name_valid:
			status_label.text = "Please enter a character name."
		elif not class_valid:
			status_label.text = "Please select a class."


func _on_start_adventure_pressed(_text = ""):
	var name_valid = not name_edit.text.strip_edges().is_empty()
	var class_valid = not selected_class.is_empty()

	if not (name_valid and class_valid):
		printerr("Start Adventure pressed with invalid input.")
		_validate_input()
		return
	
	if load_base_class(selected_class):
		PlayerData.set_base_health(current_class["base_health"])
		PlayerData.set_base_mana(current_class["base_mana"])
		
		PlayerData.set_strength(current_class["strength"])
		PlayerData.set_dexterity(current_class["dexterity"])
		PlayerData.set_wisdom(current_class["wisdom"])
		
	PlayerData.set_character_name(name_edit.text)
	PlayerData.set_character_class(selected_class)

	PlayerData.save_current_character_data()
	print("Character created and saved in slot", PlayerData.current_slot_index)

	get_tree().change_scene_to_file("res://scenes/main_town/town_scene.tscn")


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/character_select.tscn")
	
func load_base_class(character_class : String) -> bool:
	current_class = {} 
	var loaded_base_script = null

	var class_lower = character_class.to_lower()
	var layout_path = CLASS_SCRIPT_LOAD % class_lower

	if not ResourceLoader.exists(layout_path):
		printerr("Class: Layout script not found for class '", character_class, "' at path: ", layout_path)
		return false

	loaded_base_script = load(layout_path)
	if loaded_base_script == null:
		printerr("Class: Failed to load layout script at path: ", layout_path)
		return false

	if not loaded_base_script.has_meta("base") and not "base" in loaded_base_script:
		var base_class_data = loaded_base_script.get("base")
		if base_class_data == null:
			printerr("Class: '", layout_path, "' does not contain base static constant.")
			loaded_base_script = null
			return false
		current_class = base_class_data

	else:
		current_class = loaded_base_script.base
		
	print("Class: Successfully loaded class '", character_class, "'")
	return true
