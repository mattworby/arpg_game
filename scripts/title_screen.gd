# title_screen.gd
extends Control

func _ready():
	# Connect button signals
	$VBoxContainer/PlayButton.pressed.connect(_on_play_button_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_button_pressed)
	$VBoxContainer/CreditsButton.pressed.connect(_on_credits_button_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_button_pressed)

func _on_play_button_pressed():
	# Change to town scene
	get_tree().change_scene_to_file("res://scenes/main_town/town_scene.tscn")

func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/settings_scene.tscn")

func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/credits_scene.tscn")

func _on_exit_button_pressed():
	# Exit the game
	get_tree().quit()
