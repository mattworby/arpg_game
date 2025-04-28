extends Control

@onready var slot_containers: Array[HBoxContainer] = [
	$VBoxContainer/SlotContainer0,
	$VBoxContainer/SlotContainer1,
	$VBoxContainer/SlotContainer2
]
@onready var back_button: Button = $BackButton
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog

var _slot_to_delete: int = -1

func _ready():
	if not PlayerData:
		printerr("CharacterSelect Error: PlayerData Autoload not found!")
		get_tree().quit()
		return

	for i in range(PlayerData.MAX_SLOTS):
		_update_slot_display(i)

	back_button.pressed.connect(_on_back_button_pressed)
	confirmation_dialog.confirmed.connect(_on_delete_confirmed)


func _update_slot_display(slot_index: int):
	if slot_index < 0 or slot_index >= len(slot_containers): return

	var container = slot_containers[slot_index]
	var info_button: Button = container.get_node("CharInfoButton")
	var delete_button: Button = container.get_node("DeleteButton")

	# Disconnect previous signals
	if info_button.is_connected("pressed", _on_load_character_pressed):
		info_button.pressed.disconnect(_on_load_character_pressed)
	if info_button.is_connected("pressed", _on_go_to_create_character_pressed):
		info_button.pressed.disconnect(_on_go_to_create_character_pressed)
	if delete_button.is_connected("pressed", _on_delete_button_pressed):
		delete_button.pressed.disconnect(_on_delete_button_pressed)

	var slot_info = PlayerData.get_slot_info(slot_index)

	if not slot_info.is_empty():
		var char_name = slot_info.get("name", "Unknown")
		var char_class = slot_info.get("class", "Unknown")
		info_button.text = "Slot %d: %s (%s)" % [slot_index + 1, char_name, char_class]
		info_button.pressed.connect(_on_load_character_pressed.bind(slot_index))

		delete_button.visible = true
		delete_button.pressed.connect(_on_delete_button_pressed.bind(slot_index))
	else:
		info_button.text = "Slot %d: Create New Character" % (slot_index + 1)
		info_button.pressed.connect(_on_go_to_create_character_pressed.bind(slot_index))
		delete_button.visible = false


func _on_load_character_pressed(slot_index: int):
	print("Load button pressed for slot:", slot_index)
	if PlayerData.load_character_data(slot_index):
		get_tree().change_scene_to_file("res://scenes/main_town/town_scene.tscn")
	else:
		printerr("Failed to load character data for slot ", slot_index)
		_update_slot_display(slot_index)

func _on_go_to_create_character_pressed(slot_index: int):
	print("Create button pressed for slot:", slot_index)
	PlayerData.set_current_slot(slot_index)
	PlayerData.reset_to_defaults()
	get_tree().change_scene_to_file("res://scenes/menus/character_creation.tscn")

func _on_delete_button_pressed(slot_index: int):
	print("Delete button pressed for slot:", slot_index)
	_slot_to_delete = slot_index
	confirmation_dialog.dialog_text = "Are you sure you want to delete %s? This cannot be undone." % slot_containers[slot_index].get_node("CharInfoButton").text
	confirmation_dialog.popup_centered()

func _on_delete_confirmed():
	print("Deletion confirmed for slot:", _slot_to_delete)
	if _slot_to_delete != -1:
		if PlayerData.delete_character_data(_slot_to_delete):
			print("Character data deleted successfully from PlayerData.")
			_update_slot_display(_slot_to_delete)
		else:
			printerr("PlayerData reported an error deleting slot ", _slot_to_delete)
		_slot_to_delete = -1

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
