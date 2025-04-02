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

var passive_nodes = {}
var connection_lines = {}
var active_passives = {}

var is_dragging = false
var drag_start_mouse_position = Vector2.ZERO
var drag_start_container_position = Vector2.ZERO

const TREE_LAYOUT = {
	"start":      { "type": "start",     "pos": Vector2(100, 400), "connections": ["str1", "str2", "str3"] },

	# Branch 1 (Top)
	"str1":       { "type": "strength",  "pos": Vector2(300, 200), "connections": ["str1_dex1", "str1_wis1"] },
	"str1_dex1":  { "type": "dexterity", "pos": Vector2(500, 150), "connections": ["str1_dex1_str1"] },
	"str1_dex1_str1": { "type": "strength", "pos": Vector2(700, 150), "connections": ["str1_dex1_str1_wis1"] },
	"str1_dex1_str1_wis1": { "type": "wisdom", "pos": Vector2(900, 150), "connections": [] },
	"str1_wis1":  { "type": "wisdom",    "pos": Vector2(500, 250), "connections": ["str1_wis1_dex1"] },
	"str1_wis1_dex1": { "type": "dexterity", "pos": Vector2(700, 250), "connections": [] },

	# Branch 2 (Middle)
	"str2":       { "type": "strength",  "pos": Vector2(300, 400), "connections": ["str2_wis1", "str2_wis2"] },
	"str2_wis1":  { "type": "wisdom",    "pos": Vector2(500, 350), "connections": ["str2_wis1_str1"] },
	"str2_wis1_str1": { "type": "strength", "pos": Vector2(700, 350), "connections": [] },
	"str2_wis2":  { "type": "wisdom",    "pos": Vector2(500, 450), "connections": ["str2_wis2_dex1"] },
	"str2_wis2_dex1": { "type": "dexterity", "pos": Vector2(700, 450), "connections": ["str2_wis2_dex1_str1"] },
	"str2_wis2_dex1_str1": { "type": "strength", "pos": Vector2(900, 450), "connections": [] },

	# Branch 3 (Bottom)
	"str3":       { "type": "strength",  "pos": Vector2(300, 600), "connections": ["str3_dex1", "str3_str1"] },
	"str3_dex1":  { "type": "dexterity", "pos": Vector2(500, 550), "connections": ["str3_dex1_wis1"] },
	"str3_dex1_wis1": { "type": "wisdom", "pos": Vector2(700, 550), "connections": ["str3_dex1_wis1_dex1"] },
	"str3_dex1_wis1_dex1": { "type": "dexterity", "pos": Vector2(900, 550), "connections": [] },
	"str3_str1":  { "type": "strength",  "pos": Vector2(500, 650), "connections": ["str3_str1_wis1"] },
	"str3_str1_wis1": { "type": "wisdom", "pos": Vector2(700, 650), "connections": ["str3_str1_wis1_str1"] },
	"str3_str1_wis1_str1": { "type": "strength", "pos": Vector2(900, 650), "connections": [] },

	# Example of adding more nodes later:
	# "another_node": { "type": "dexterity", "pos": Vector2(1100, 150), "connections": [] },
	# And update "str1_dex1_str1_wis1"'s connections:
	# "str1_dex1_str1_wis1": { "type": "wisdom", "pos": Vector2(900, 150), "connections": ["another_node"] },
}

@onready var tree_container: Control = $TreeContainer
@onready var background: ColorRect = $PassiveTreeBackground

func _ready():
	if GlobalPassive.player_passive_tree.is_empty():
		GlobalPassive.player_passive_tree["start"] = true
	
	active_passives = GlobalPassive.player_passive_tree.duplicate()
	background.process_mode = process_mode
	background.gui_input.connect(_on_background_gui_input)
	build_tree()

func toggle_passive_tree():
	visible = !visible
	if visible:
		update_visuals()

func build_tree():
	# Clear previous nodes/lines inside the container
	for child in tree_container.get_children():
		child.queue_free()

	passive_nodes.clear()
	connection_lines.clear()

	# --- Create Nodes from TREE_LAYOUT ---
	for node_id in TREE_LAYOUT:
		var node_layout_data = TREE_LAYOUT[node_id]
		var passive_info = PASSIVE_DATABASE.get_passive(node_layout_data.type)

		if passive_info == null:
			printerr("Passive type '%s' not found in database for node '%s'!" % [node_layout_data.type, node_id])
			continue # Skip this node if data is missing

		var node_instance = _create_passive_node(node_id, passive_info, node_layout_data.pos)

		# Specific handling for the start node
		if node_id == "start":
			node_instance.disabled = true
			node_instance.modulate = NORMAL_COLOR # Always bright
		else:
			# Connect pressed signal for all non-start nodes
			# We use bind to pass the node_id to the handler
			node_instance.pressed.connect(_on_passive_node_pressed.bind(node_id))

		tree_container.add_child(node_instance)
		passive_nodes[node_id] = node_instance

	# --- Create Connections from TREE_LAYOUT ---
	# Create lines *after* all nodes exist
	for from_id in TREE_LAYOUT:
		var from_node_data = TREE_LAYOUT[from_id]
		var from_pos = from_node_data.pos

		# Check if the source node was actually created (passive_info wasn't null)
		if not passive_nodes.has(from_id):
			continue

		for to_id in from_node_data.connections:
			# Check if the destination node ID is valid and exists
			if TREE_LAYOUT.has(to_id) and passive_nodes.has(to_id):
				var to_pos = TREE_LAYOUT[to_id].pos
				var connection_id = "%s-%s" % [from_id, to_id]

				var line_instance = _create_connection_line(from_id, to_id, from_pos, to_pos)
				tree_container.add_child(line_instance)
				line_instance.z_index = -1 # Draw lines behind nodes
				connection_lines[connection_id] = line_instance
			else:
				printerr("Cannot create connection from '%s' to invalid or non-existent node '%s'" % [from_id, to_id])


	# Set initial visual state based on active passives
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

	return node

func _create_connection_line(from_id: String, to_id: String, pos_from: Vector2, pos_to: Vector2) -> Line2D:
	var line = Line2D.new()
	line.name = "Line_%s_%s" % [from_id, to_id]
	line.add_point(pos_from)
	line.add_point(pos_to)
	line.width = LINE_WIDTH
	line.default_color = LINE_INACTIVE_COLOR
	line.antialiased = true
	return line

func update_visuals():
	# Update Node Appearance
	for node_id in passive_nodes:
		var node = passive_nodes[node_id]

		# Special handling for start node (always bright, always disabled)
		if node_id == "start":
			node.modulate = NORMAL_COLOR
			node.disabled = true # Start node cannot be clicked/deactivated
			continue # Skip rest of logic for start node

		# Logic for other nodes
		if active_passives.has(node_id):
			# Node is Active: Make it bright and *clickable* for deactivation
			node.modulate = NORMAL_COLOR
			node.disabled = false # Allow clicking active nodes to deactivate
		else:
			# Node is Inactive: Check if it can be activated
			var can_activate = _can_activate_node(node_id)
			if can_activate:
				# Can be activated: Make it dim and clickable
				node.modulate = DIM_COLOR
				node.disabled = false
			else:
				# Cannot be activated: Make it very dim and disabled
				node.modulate = DIM_COLOR * Color(0.6, 0.6, 0.6, 1.0)
				node.disabled = true

	# Update Line Appearance (logic remains the same)
	for connection_id in connection_lines:
		var line = connection_lines[connection_id]
		var parts = connection_id.split("-")
		var from_id = parts[0]
		var to_id = parts[1]

		if active_passives.has(from_id) and active_passives.has(to_id):
			line.default_color = LINE_ACTIVE_COLOR
		else:
			line.default_color = LINE_INACTIVE_COLOR

func _on_passive_node_pressed(passive_id: String):
	# Cannot interact with the start node via click
	if passive_id == "start":
		return

	var changed = false
	if active_passives.has(passive_id):
		# --- Deactivation ---
		# Node is currently active, so deactivate it and its dependents
		_deactivate_node_and_dependents(passive_id)
		changed = true
	else:
		# --- Activation ---
		# Node is not active, check if it *can* be activated
		if _can_activate_node(passive_id):
			print("Activating node: ", passive_id)
			active_passives[passive_id] = true # Mark as active locally
			changed = true
		else:
			# Button should have been disabled, but log if somehow clicked
			printerr("Attempted to press node '%s' that cannot be activated!" % passive_id)

	# If any change occurred (activation or deactivation)
	if changed:
		# Update visuals immediately
		update_visuals()
		# Emit signal with the complete updated data
		emit_signal("passive_tree_changed", active_passives)
			
func _on_background_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_mouse_position = get_global_mouse_position()
				drag_start_container_position = tree_container.position

			else:
				is_dragging = false

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				var zoom_direction = 1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0
				var zoom_increment = pow(ZOOM_FACTOR, zoom_direction) 

				var mouse_pos = get_local_mouse_position() 
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
			# Optional: Clamp tree_container.position within bounds here
			# clamp_container_position()
			
func _can_activate_node(node_id: String) -> bool:
	# Node already active? Cannot activate again.
	if active_passives.has(node_id):
		return false

	# Start node doesn't need activation check (it's active by default)
	if node_id == "start":
		return false # Cannot be activated via click

	# Check nodes connected directly from 'start'
	var start_node_data = TREE_LAYOUT["start"]
	if start_node_data.connections.has(node_id):
		# Requires 'start' node to be active (which it always should be)
		return active_passives.has("start")

	# Check other nodes: requires at least one active *direct* prerequisite
	# Iterate through the layout to find nodes that connect TO this node_id
	for potential_prereq_id in TREE_LAYOUT:
		var prereq_data = TREE_LAYOUT[potential_prereq_id]
		# Check if this potential prerequisite node connects to our target node_id
		if prereq_data.connections.has(node_id):
			# Check if this prerequisite node is currently active
			if active_passives.has(potential_prereq_id):
				# Found an active prerequisite, so this node can be activated
				return true

	# No active prerequisites found
	return false
	
func _has_active_prerequisite(node_id: String) -> bool:
	# Start node doesn't have prerequisites in the conventional sense
	if node_id == "start":
		return false # Or true, depending on definition, but it cannot be deactivated.

	# Nodes directly connected from start only require start
	var start_node_data = TREE_LAYOUT["start"]
	if start_node_data.connections.has(node_id):
		return active_passives.has("start") # Should always be true if start exists

	# Check other nodes: requires at least one active *direct* prerequisite
	for potential_prereq_id in TREE_LAYOUT:
		var prereq_data = TREE_LAYOUT[potential_prereq_id]
		# Check if this potential prerequisite node connects to our target node_id
		if prereq_data.connections.has(node_id):
			# Check if this prerequisite node is currently active
			if active_passives.has(potential_prereq_id):
				# Found an active prerequisite
				return true

	# No active prerequisites found
	return false
	
func _deactivate_node_and_dependents(node_id_to_deactivate: String):
	# Cannot deactivate the start node
	if node_id_to_deactivate == "start":
		printerr("Cannot deactivate the start node.")
		return

	# Only proceed if the node is actually active
	if not active_passives.has(node_id_to_deactivate):
		return

	# 1. Deactivate the target node
	print("Deactivating node: ", node_id_to_deactivate)
	active_passives.erase(node_id_to_deactivate) # Remove from active set

	# 2. Check nodes that DEPEND ON the deactivated node (its children in the layout)
	if TREE_LAYOUT.has(node_id_to_deactivate):
		var node_data = TREE_LAYOUT[node_id_to_deactivate]
		for child_id in node_data.connections:
			# Only check children that were previously active
			if active_passives.has(child_id):
				# If this child no longer has *any* active prerequisites after
				# we removed node_id_to_deactivate, deactivate it too.
				if not _has_active_prerequisite(child_id):
					# Recursively call deactivation for the dependent child
					_deactivate_node_and_dependents(child_id)
