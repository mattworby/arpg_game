extends Camera2D

@export var target_node_path: NodePath
@onready var target = get_node_or_null(target_node_path) if target_node_path and not target_node_path.is_empty() else null

func _ready():
	if not is_instance_valid(target): 
		print("PlayerCamera: Target not set via export or invalid. Searching...")
		var parent = get_parent()
		while parent and not is_instance_valid(target):
			if parent.is_in_group("player"):
				target = parent
				print("PlayerCamera: Found target in parent: ", target.name)
				break
			parent = parent.get_parent()

		if not is_instance_valid(target):
			print("PlayerCamera: Target not found in parents. Searching group 'player'...")
			var players = get_tree().get_nodes_in_group("player")
			if players.size() > 0:
				target = players[0]
				print("PlayerCamera: Found target in group: ", target.name)
			else:
				printerr("PlayerCamera Warning: Could not find player node to target!")
				target = null

	if GlobalInventory:
		print("PlayerCamera: Calling GlobalInventory.initialize_inventory()")
		GlobalInventory.initialize_inventory()
	else:
		printerr("PlayerCamera FATAL ERROR: GlobalInventory Autoload node not found!")

func _process(delta):
	if target:
		global_position = target.global_position
