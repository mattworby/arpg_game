# credits_scene.gd
extends Control

func _ready():
	$BackButton.pressed.connect(_on_back_button_pressed)
	
	# Optional: Animate the credits to automatically scroll
	# var tween = create_tween()
	# tween.tween_property($ScrollContainer, "scroll_vertical", $ScrollContainer/VBoxContainer.size.y, 20)
	# tween.set_trans(Tween.TRANS_LINEAR)

func _on_back_button_pressed():
	# Go back to the title screen
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
