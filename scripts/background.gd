extends Node2D

func _ready():
	# Find the background ColorRect or create one if it doesn't exist
	var background = $Background
	if not background:
		background = ColorRect.new()
		background.name = "Background"
		background.anchors_preset = Control.PRESET_FULL_RECT
		add_child(background)
	
	# Set background to green
	background.color = Color.GREEN
