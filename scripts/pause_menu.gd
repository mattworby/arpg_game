extends CanvasLayer

signal resume_game
signal go_to_settings
signal exit_to_menu

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS  # Ensure menu works when game paused

# Remove the _input handler as GlobalPause now handles this

func _on_resume_button_pressed():
	emit_signal("resume_game")

func _on_settings_button_pressed():
	emit_signal("go_to_settings")

func _on_main_menu_button_pressed():
	emit_signal("exit_to_menu")
