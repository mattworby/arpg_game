# passive_treeManager.gd - Add this as an autoload/singleton
extends Node

signal passive_tree_updated

var passive_tree_scene = preload("res://scenes/menus/passive_tree/passive_tree.tscn")
var passive_tree_instance = null
var player_passive_tree = {}

func _ready():
	# Create passive_tree instance
	passive_tree_instance = passive_tree_scene.instantiate()
	passive_tree_instance.visible = false
	# Don't add to tree yet - will be added on demand

	# Connect signals from passive_tree
	passive_tree_instance.passive_tree_changed.connect(_on_passive_tree_changed)

func _input(event):
	if event is InputEventKey and event.pressed and not event.is_echo() and !get_tree().get_current_scene().name == "TitleScreen":
		if event.keycode == KEY_P and !get_tree().paused:
			toggle_passive_tree()

func toggle_passive_tree():
	var player = get_tree().get_first_node_in_group("player")
	# Only add passive_tree when needed
	if !passive_tree_instance.is_inside_tree():
		# Get current camera and add passive_tree as its child
		var viewport = get_tree().get_root().get_viewport()
		var camera = viewport.get_camera_2d()
		var screen_size = viewport.get_visible_rect().size
		
		if camera:
			camera.add_child(passive_tree_instance)		
			
			# Ensure passive_tree is in front with higher z_index
			passive_tree_instance.z_index = 100
			passive_tree_instance.position.x = 0 - screen_size.x/2
			passive_tree_instance.position.y = 0 - screen_size.y/2
			passive_tree_instance.size.x = screen_size.x
			passive_tree_instance.size.y = screen_size.y
			
			if player:
				player.lock_movement()
			
			passive_tree_instance.toggle_passive_tree()
	else:
		var parent = passive_tree_instance.get_parent()
		if parent:
			parent.remove_child(passive_tree_instance)
			passive_tree_instance.toggle_passive_tree()
			if player:
				player.unlock_movement()

func _on_passive_tree_changed(data):
	# Store updated passive_tree data
	player_passive_tree = data
	emit_signal("passive_tree_updated")
