extends Control

func _ready():
	# Connect back button
	$MarginContainer/VBoxContainer/HBoxContainer/BackButton.pressed.connect(_on_back_button_pressed)
	$MarginContainer/VBoxContainer/HBoxContainer/ApplyButton.pressed.connect(_on_apply_button_pressed)
	
	# Connect gameplay buttons
	$MarginContainer/VBoxContainer/TabContainer/Gameplay/VBoxContainer/DifficultyOption/Button.pressed.connect(
		func(): print("difficulty")
	)
	$MarginContainer/VBoxContainer/TabContainer/Gameplay/VBoxContainer/TutorialOption/CheckButton.toggled.connect(
		func(toggled_on): print("tutorial: ", toggled_on)
	)
	
	# Connect graphics buttons
	$MarginContainer/VBoxContainer/TabContainer/Graphics/VBoxContainer/ResolutionOption/OptionButton.item_selected.connect(
		func(index): print("resolution: ", index)
	)
	$MarginContainer/VBoxContainer/TabContainer/Graphics/VBoxContainer/FullscreenOption/CheckButton.toggled.connect(
		func(toggled_on): print("fullscreen: ", toggled_on)
	)
	$MarginContainer/VBoxContainer/TabContainer/Graphics/VBoxContainer/VSyncOption/CheckButton.toggled.connect(
		func(toggled_on): print("vsync: ", toggled_on)
	)
	
	# Connect audio sliders
	$MarginContainer/VBoxContainer/TabContainer/Audio/VBoxContainer/MasterVolumeOption/HSlider.value_changed.connect(
		func(value): print("master volume: ", value)
	)
	$MarginContainer/VBoxContainer/TabContainer/Audio/VBoxContainer/MusicVolumeOption/HSlider.value_changed.connect(
		func(value): print("music volume: ", value)
	)
	$MarginContainer/VBoxContainer/TabContainer/Audio/VBoxContainer/SFXVolumeOption/HSlider.value_changed.connect(
		func(value): print("sfx volume: ", value)
	)

func _on_back_button_pressed():
	# Go back to the title screen
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_apply_button_pressed():
	print("apply settings")
