extends Camera2D

# Reference to the player character
@export var target_node_path: NodePath
@onready var target = get_node(target_node_path) if not target_node_path.is_empty() else null

func _ready():
	if target == null:
		var parent = get_parent()
		while parent and not target:
			if parent.is_in_group("player"):
				target = parent
				break
			parent = parent.get_parent()
		
		if target == null:
			var players = get_tree().get_nodes_in_group("player")
			if players.size() > 0:
				target = players[0]

func _process(delta):
	if target:
		global_position = target.global_position
