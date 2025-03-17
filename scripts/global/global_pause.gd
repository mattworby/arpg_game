extends Node

var pause_menu_scene = preload("res://scenes/menus/pause_menu.tscn")
var pause_menu
var is_paused = false

var exclude_scenes = ["PauseMenu", "TitleScreen"]

func _ready():
	pause_menu = pause_menu_scene.instantiate()
	
	pause_menu.resume_game.connect(_on_resume_game)
	pause_menu.go_to_settings.connect(_on_go_to_settings)
	pause_menu.exit_to_menu.connect(_on_exit_to_menu)
	
	get_tree().root.call_deferred("add_child", pause_menu)
	pause_menu.hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		var current_scene = get_tree().current_scene.name
		
		if not current_scene in exclude_scenes:
			toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	
	if is_paused:
		pause_menu.show()
		get_tree().paused = true
	else:
		pause_menu.hide()
		get_tree().paused = false

func _on_resume_game():
	toggle_pause()

func _on_go_to_settings():
	get_tree().paused = false
	pause_menu.hide()
	get_tree().change_scene_to_file("res://scenes/menus/settings_scene.tscn")

func _on_exit_to_menu():
	is_paused = false
	get_tree().paused = false
	pause_menu.hide()
	get_tree().change_scene_to_file("res://scenes/menus/title_screen.tscn")
