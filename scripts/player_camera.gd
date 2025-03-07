extends Camera2D

# Reference to the player character
@export var target_node_path: NodePath
@onready var target = get_node(target_node_path) if not target_node_path.is_empty() else null

func _ready():
	# Find player if not set via export
	if target == null:
		var player = get_node("/root/MainScene/Player/CharacterBody2D")
		if player:
			target = player

func _process(delta):
	if target:
		# Update camera position to follow target
		global_position = target.global_position
