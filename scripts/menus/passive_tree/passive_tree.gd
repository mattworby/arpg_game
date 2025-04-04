extends Control

signal passive_tree_changed(data)

const PASSIVE_DATABASE = preload("res://scripts/menus/passive_tree/passive_database.gd")
const NODE_SIZE = Vector2(64, 64)
const LINE_WIDTH = 4.0
const DIM_COLOR = Color(0.5, 0.5, 0.5, 1.0)
const NORMAL_COLOR = Color(1.0, 1.0, 1.0, 1.0)
const LINE_INACTIVE_COLOR = Color(0.7, 0.7, 0.7, 0.8) 
const LINE_ACTIVE_COLOR = Color(1.0, 1.0, 0.0, 1.0) 

const ZOOM_FACTOR = 1.1 
const MIN_ZOOM = 0.5
const MAX_ZOOM = 1.0  

# --- NEW: Layout Loading ---
const LAYOUT_SCRIPT_PATH_FORMAT = "res://scripts/menus/passive_tree/layouts/%s_passive_tree.gd"
var current_tree_layout: Dictionary = {}
var loaded_layout_script = null
var current_loaded_class : String = "" 

var active_passives: Dictionary = {}
var pending_passives: Dictionary = {}
var initial_passives: Dictionary = {}

var passive_nodes = {}
var connection_lines = {}

var is_dragging = false
var drag_start_mouse_position = Vector2.ZERO
var drag_start_container_position = Vector2.ZERO


@onready var tree_container: Control = $TreeContainer
@onready var background: ColorRect = $PassiveTreeBackground
@onready var confirmation_controls: Container = $ConfirmationControls
@onready var confirm_button: Button = $ConfirmationControls/ButtonContainer/ConfirmButton
@onready var cancel_button: Button = $ConfirmationControls/ButtonContainer/CancelButton

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	background.process_mode = process_mode
	background.gui_input.connect(_on_background_gui_input)
	
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

	if GlobalPassive.player_passive_tree:
		active_passives = GlobalPassive.player_passive_tree.duplicate()
		initial_passives = active_passives
	else:
		active_passives = {"start": true} if GlobalPassive.player_passive_tree else {}
		if GlobalPassive.player_passive_tree == null or GlobalPassive.player_passive_tree.is_empty():
			GlobalPassive.player_passive_tree = active_passives.duplicate()


func toggle_passive_tree():
	visible = !visible
	if visible:
		var player_class = PlayerData.get_character_class()
		if player_class.is_empty():
			printerr("Passive Tree: PlayerData has no character class set!")
			clear_tree_visuals()
			confirmation_controls.visible = false 
			return

		var layout_changed = (player_class != current_loaded_class)
		var load_success = true
		if layout_changed:
			print("Passive Tree: Loading layout for class: ", player_class)
			load_success = load_tree_layout(player_class)

		if load_success:
			active_passives = GlobalPassive.player_passive_tree.duplicate()
			if current_tree_layout.has("start") and not active_passives.has("start"):
					active_passives["start"] = true

			pending_passives = active_passives.duplicate()

			if layout_changed:
				build_tree()
				tree_container.scale = Vector2.ONE
				tree_container.position = Vector2.ZERO

			update_visuals()
			update_confirmation_visibility()

		else:
			clear_tree_visuals()
			active_passives = {}
			pending_passives = {}
			update_confirmation_visibility()
	else:
		confirmation_controls.visible = false
		is_dragging = false

func load_tree_layout(character_class : String) -> bool:
	current_tree_layout = {}
	loaded_layout_script = null
	current_loaded_class = ""

	var class_lower = character_class.to_lower()
	var layout_path = LAYOUT_SCRIPT_PATH_FORMAT % class_lower

	if not ResourceLoader.exists(layout_path):
		printerr("Passive Tree: Layout script not found for class '", character_class, "' at path: ", layout_path)
		return false

	# Load the script resource
	loaded_layout_script = load(layout_path)
	if loaded_layout_script == null:
		printerr("Passive Tree: Failed to load layout script at path: ", layout_path)
		return false

	if not loaded_layout_script.has_meta("TREE_LAYOUT") and not "TREE_LAYOUT" in loaded_layout_script:
		var layout_data = loaded_layout_script.get("TREE_LAYOUT") 
		if layout_data == null:
			printerr("Passive Tree: Layout script '", layout_path, "' does not contain TREE_LAYOUT static constant.")
			loaded_layout_script = null
			return false
		current_tree_layout = layout_data

	else:
		current_tree_layout = loaded_layout_script.TREE_LAYOUT


	print("Passive Tree: Successfully loaded layout for class '", character_class, "'")
	current_loaded_class = character_class
	return true
	
func clear_tree_visuals():
	for child in tree_container.get_children():
		child.queue_free()
	passive_nodes.clear()
	connection_lines.clear()


func build_tree():
	clear_tree_visuals()

	if current_tree_layout.is_empty():
		printerr("Passive Tree: Cannot build tree, no layout loaded.")
		return

	for node_id in current_tree_layout:
		var node_layout_data = current_tree_layout[node_id]
		if not node_layout_data.has("type") or not node_layout_data.has("pos"):
			printerr("Passive Tree: Node '%s' in layout is missing 'type' or 'pos'." % node_id)
			continue

		var passive_info = PASSIVE_DATABASE.get_passive(node_layout_data.type)
		if passive_info == null:
			printerr("Passive Tree: Passive type '%s' not found in database for node '%s'!" % [node_layout_data.type, node_id])
			continue

		var node_instance = _create_passive_node(node_id, passive_info, node_layout_data.pos)

		if node_id == "start":
			node_instance.disabled = true
			node_instance.modulate = NORMAL_COLOR
		else:
			node_instance.pressed.connect(_on_passive_node_pressed.bind(node_id))

		tree_container.add_child(node_instance)
		passive_nodes[node_id] = node_instance

	for from_id in current_tree_layout:
		var from_node_data = current_tree_layout[from_id]
		var from_pos = from_node_data.get("pos", Vector2.ZERO)

		if not passive_nodes.has(from_id): continue 

		var connections = from_node_data.get("connections", [])
		if not typeof(connections) == TYPE_ARRAY:
			printerr("Passive Tree: Node '%s' has invalid 'connections' data." % from_id)
			continue

		for to_id in connections:
			if not typeof(to_id) == TYPE_STRING:
				printerr("Passive Tree: Invalid connection ID type found for node '%s'" % from_id)
				continue

			if current_tree_layout.has(to_id) and passive_nodes.has(to_id):
				var to_pos = current_tree_layout[to_id].get("pos", Vector2.ZERO)
				var connection_id = "%s-%s" % [from_id, to_id]

				var line_instance = _create_connection_line(from_id, to_id, from_pos, to_pos)
				tree_container.add_child(line_instance)
				line_instance.z_index = -1
				connection_lines[connection_id] = line_instance
			else:
				printerr("Cannot create connection from '%s' to invalid or non-existent node '%s'" % [from_id, to_id])

	update_visuals()


func _create_passive_node(passive_id: String, data: Dictionary, pos: Vector2) -> TextureButton:

	var node = TextureButton.new()
	node.name = passive_id
	node.texture_normal = load(data.image)
	node.custom_minimum_size = NODE_SIZE
	node.ignore_texture_size = true
	node.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	node.position = pos - (NODE_SIZE / 2.0)
	node.tooltip_text = "%s\n%s" % [data.name, data.description]
	node.mouse_filter = Control.MOUSE_FILTER_STOP
	node.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	return node

func _create_connection_line(from_id: String, to_id: String, pos_from: Vector2, pos_to: Vector2) -> Line2D:
	var line = Line2D.new()
	line.name = "Line_%s_%s" % [from_id, to_id]
	line.add_point(pos_from)
	line.add_point(pos_to)
	line.width = LINE_WIDTH
	line.default_color = LINE_INACTIVE_COLOR
	return line


func update_visuals():
	if current_tree_layout.is_empty():
		clear_tree_visuals()
		return

	for node_id in passive_nodes:
		var node = passive_nodes[node_id]
		if node_id == "start":
			node.modulate = NORMAL_COLOR
			node.disabled = true
			continue

		if pending_passives.has(node_id):
			node.modulate = NORMAL_COLOR
			node.disabled = false
		else:
			var can_activate = _can_activate_node(node_id)
			if can_activate:
				node.modulate = DIM_COLOR
				node.disabled = false
			else:
				node.modulate = DIM_COLOR * Color(0.6, 0.6, 0.6, 1.0)
				node.disabled = true

	for connection_id in connection_lines:
		var line = connection_lines[connection_id]
		var parts = connection_id.split("-")
		var from_id = parts[0]
		var to_id = parts[1]
		if pending_passives.has(from_id) and pending_passives.has(to_id):
			line.default_color = LINE_ACTIVE_COLOR
		else:
			line.default_color = LINE_INACTIVE_COLOR

func update_confirmation_visibility():
	var changes_pending = (pending_passives != active_passives)
	confirmation_controls.visible = changes_pending

func _on_passive_node_pressed(passive_id: String):
	if current_tree_layout.is_empty(): return
	if passive_id == "start": return

	var changed_pending_state = false
	if pending_passives.has(passive_id):
		_deactivate_node_and_dependents(passive_id)
		changed_pending_state = true
	else:
		if _can_activate_node(passive_id):
			pending_passives[passive_id] = true
			changed_pending_state = true
		else:
			printerr("Attempted to press node '%s' that cannot be activated!" % passive_id)

	if changed_pending_state:
		update_visuals()
		update_confirmation_visibility()
			
func _on_background_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_mouse_position = get_global_mouse_position()
				drag_start_container_position = tree_container.position
				accept_event()
			else:
				is_dragging = false
				accept_event()

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				var zoom_direction = 1.0 if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1.0
				var zoom_increment = pow(ZOOM_FACTOR, zoom_direction)
				var target_scale = tree_container.scale * zoom_increment
				target_scale.x = clampf(target_scale.x, MIN_ZOOM, MAX_ZOOM)
				target_scale.y = clampf(target_scale.y, MIN_ZOOM, MAX_ZOOM)

				if not is_equal_approx(tree_container.scale.x, target_scale.x):
					var mouse_pos_in_container = tree_container.get_local_mouse_position()
					var old_scale = tree_container.scale
					tree_container.scale = target_scale
					tree_container.position += mouse_pos_in_container * old_scale - mouse_pos_in_container * target_scale
					accept_event()

	elif event is InputEventMouseMotion:
		if is_dragging:
			var mouse_delta = get_global_mouse_position() - drag_start_mouse_position
			tree_container.position = drag_start_container_position + mouse_delta
			accept_event()

func _can_activate_node(node_id: String) -> bool:
	if current_tree_layout.is_empty() or not current_tree_layout.has(node_id): return false
	if pending_passives.has(node_id): return false 
	if node_id == "start": return false

	if current_tree_layout.has("start"):
		var start_node_data = current_tree_layout["start"]
		var start_connections = start_node_data.get("connections", [])
		if typeof(start_connections) == TYPE_ARRAY and start_connections.has(node_id):
			return true

	for potential_prereq_id in current_tree_layout:
		var prereq_data = current_tree_layout[potential_prereq_id]
		var connections = prereq_data.get("connections", [])
		if typeof(connections) == TYPE_ARRAY and connections.has(node_id):
			if pending_passives.has(potential_prereq_id):
				return true
	return false

func _has_active_prerequisite(node_id: String) -> bool:
	if current_tree_layout.is_empty() or not current_tree_layout.has(node_id): return false
	if node_id == "start": return false

	if current_tree_layout.has("start"):
		var start_node_data = current_tree_layout["start"]
		var start_connections = start_node_data.get("connections", [])
		if typeof(start_connections) == TYPE_ARRAY and start_connections.has(node_id):
			return true

	for potential_prereq_id in current_tree_layout:
		var prereq_data = current_tree_layout[potential_prereq_id]
		var connections = prereq_data.get("connections", [])
		if typeof(connections) == TYPE_ARRAY and connections.has(node_id):
			if pending_passives.has(potential_prereq_id):
				return true
	return false
	
func _deactivate_node_and_dependents(node_id_to_deactivate: String):
	if current_tree_layout.is_empty(): return
	if node_id_to_deactivate == "start": return
	if not pending_passives.has(node_id_to_deactivate): return

	pending_passives.erase(node_id_to_deactivate)

	if current_tree_layout.has(node_id_to_deactivate):
		var node_data = current_tree_layout[node_id_to_deactivate]
		var connections = node_data.get("connections", [])
		if typeof(connections) == TYPE_ARRAY:
			for child_id in connections:
				if typeof(child_id) == TYPE_STRING and pending_passives.has(child_id):
					if not _has_active_prerequisite(child_id):
						_deactivate_node_and_dependents(child_id)
						
func _on_confirm_pressed():
	print("Confirming passive changes.")
	active_passives = pending_passives.duplicate()
	GlobalPassive.player_passive_tree = active_passives.duplicate()
	GlobalPassive.save_passives_for_current_slot()
	print(GlobalPassive.player_passive_tree)
	print(initial_passives)
	for old_passive in initial_passives:
		if(!GlobalPassive.player_passive_tree.has(old_passive)):
			update_passives(old_passive, "remove")
	print("test")
	for passive in GlobalPassive.player_passive_tree:
		if(initial_passives.is_empty() and !initial_passives.has(passive)):
			update_passives(passive, "added")
	
	update_confirmation_visibility()
	PlayerData.save_current_character_data()
	initial_passives = GlobalPassive.player_passive_tree
	emit_signal("passive_tree_changed", active_passives)

func _on_cancel_pressed():
	print("Cancelling passive changes.")
	pending_passives = active_passives.duplicate()
	update_visuals()
	update_confirmation_visibility()
	
func update_passives(passive, sign):
	var value = 0
	
	for attribute in current_tree_layout[passive].get("buffs", {}):
		if sign == "added":
			value = current_tree_layout[passive].get("buffs", {})[attribute]
		else:
			value = 0 - current_tree_layout[passive].get("buffs", {})[attribute]
		
		match attribute:
			"strength":
				PlayerData.set_strength(PlayerData.get_strength() + value)
			"dexterity":
				PlayerData.set_dexterity(PlayerData.get_dexterity() + value)
			"wisdom":
				PlayerData.set_wisdom(PlayerData.get_wisdom() + value)
