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
var current_tree_layout: Dictionary = {} # Holds the loaded layout data
var loaded_layout_script = null # Holds the Resource of the loaded layout script
var current_loaded_class : String = "" # Track which class layout is loaded

var passive_nodes = {}
var connection_lines = {}
var active_passives = {}

var is_dragging = false
var drag_start_mouse_position = Vector2.ZERO
var drag_start_container_position = Vector2.ZERO


@onready var tree_container: Control = $TreeContainer
@onready var background: ColorRect = $PassiveTreeBackground

func _ready():
		# Set process mode needed for pause interaction
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	background.process_mode = process_mode # Match parent
	background.gui_input.connect(_on_background_gui_input)

	# Initial load of active passives from GlobalPassive
	# This assumes GlobalPassive manages loading/saving the active passives dictionary
	# associated with the currently loaded PlayerData slot.
	# We will load the *layout* when the tree is toggled on.
	if GlobalPassive.player_passive_tree: # Check if it's populated
		active_passives = GlobalPassive.player_passive_tree.duplicate()
	else:
		# Initialize with start if GlobalPassive is empty (e.g., new game before first save)
		active_passives = {"start": true} if GlobalPassive.player_passive_tree else {}
		# Ensure GlobalPassive also gets this default if it was truly null/empty
		if GlobalPassive.player_passive_tree == null or GlobalPassive.player_passive_tree.is_empty():
			GlobalPassive.player_passive_tree = active_passives.duplicate()


func toggle_passive_tree():
	visible = !visible
	if visible:
		# --- Load Layout Based on Class ---
		var player_class = PlayerData.get_character_class() # Get class from Autoload
		if player_class.is_empty():
			printerr("Passive Tree: PlayerData has no character class set!")
			# Handle error - maybe show nothing or a default message?
			clear_tree_visuals()
			return

		# Check if the correct layout is already loaded
		if player_class != current_loaded_class:
			print("Passive Tree: Loading layout for class: ", player_class)
			if load_tree_layout(player_class):
				# Successfully loaded new layout, rebuild visuals
				# Reload active passives from GlobalPassive in case they were updated
				# for this character slot since last time tree was open
				active_passives = GlobalPassive.player_passive_tree.duplicate()
				# Ensure 'start' is always active if the layout has it
				if current_tree_layout.has("start") and not active_passives.has("start"):
					active_passives["start"] = true

				build_tree() # Build visuals based on the newly loaded layout
				update_visuals() # Apply active state visuals
				# Reset zoom/pan for new layout? Optional.
				tree_container.scale = Vector2.ONE
				tree_container.position = Vector2.ZERO
			else:
				# Failed to load layout for this class
				clear_tree_visuals() # Clear any old visuals
				# Optionally show an error message on screen
		else:
			# Correct layout already loaded, just ensure visuals are up-to-date
			# Reload active passives in case points were spent elsewhere or loaded
			active_passives = GlobalPassive.player_passive_tree.duplicate()
			if current_tree_layout.has("start") and not active_passives.has("start"):
					active_passives["start"] = true
			update_visuals()
	else:
		# Tree is being hidden, no action needed currently
		pass

func load_tree_layout(character_class : String) -> bool:
	current_tree_layout = {} # Clear previous layout
	loaded_layout_script = null
	current_loaded_class = ""

	var class_lower = character_class.to_lower() # Use lowercase for filename consistency
	var layout_path = LAYOUT_SCRIPT_PATH_FORMAT % class_lower

	if not ResourceLoader.exists(layout_path):
		printerr("Passive Tree: Layout script not found for class '", character_class, "' at path: ", layout_path)
		# You could try loading a default layout here if desired
		# layout_path = LAYOUT_SCRIPT_PATH_FORMAT % "default"
		# if not ResourceLoader.exists(layout_path): return false
		return false

	# Load the script resource
	loaded_layout_script = load(layout_path)
	if loaded_layout_script == null:
		printerr("Passive Tree: Failed to load layout script at path: ", layout_path)
		return false

	# Check if the loaded script has the expected constant
	if not loaded_layout_script.has_meta("TREE_LAYOUT") and not "TREE_LAYOUT" in loaded_layout_script:
		# Note: Checking constant directly like loaded_layout_script.TREE_LAYOUT might not work
		# reliably before instantiation/without reflection in GDScript 4 for static const?
		# Let's try accessing it directly - this usually works for static const.
		# If it fails, we might need an instance or a static function getter.
		# Re-evaluating: Direct access `loaded_layout_script.TREE_LAYOUT` SHOULD work for static const.
		# Check if the property exists on the script resource itself.
		var layout_data = loaded_layout_script.get("TREE_LAYOUT") # Safer way to attempt access
		if layout_data == null:
			printerr("Passive Tree: Layout script '", layout_path, "' does not contain TREE_LAYOUT static constant.")
			loaded_layout_script = null # Unload if invalid
			return false
		current_tree_layout = layout_data

	else:
		# Handle potential edge case if has_meta works differently
		current_tree_layout = loaded_layout_script.TREE_LAYOUT


	print("Passive Tree: Successfully loaded layout for class '", character_class, "'")
	current_loaded_class = character_class # Mark which class layout we have loaded
	return true
	
func clear_tree_visuals():
	# Remove all nodes and lines from the container
	for child in tree_container.get_children():
		child.queue_free()
	passive_nodes.clear()
	connection_lines.clear()


func build_tree():
	clear_tree_visuals() # Ensure clean slate before building

	if current_tree_layout.is_empty():
		printerr("Passive Tree: Cannot build tree, no layout loaded.")
		return

	# --- Create Nodes from current_tree_layout ---
	for node_id in current_tree_layout:
		var node_layout_data = current_tree_layout[node_id]
		# Ensure required keys exist in layout data
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

	# --- Create Connections from current_tree_layout ---
	for from_id in current_tree_layout:
		var from_node_data = current_tree_layout[from_id]
		var from_pos = from_node_data.get("pos", Vector2.ZERO) # Use .get for safety

		if not passive_nodes.has(from_id): continue # Source node wasn't created

		# Check if 'connections' key exists and is an array
		var connections = from_node_data.get("connections", [])
		if not typeof(connections) == TYPE_ARRAY:
			printerr("Passive Tree: Node '%s' has invalid 'connections' data." % from_id)
			continue

		for to_id in connections:
			# Ensure to_id is a string before proceeding
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
	node.process_mode = Node.PROCESS_MODE_WHEN_PAUSED # Match parent
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
	if current_tree_layout.is_empty(): # Don't update if no layout
		clear_tree_visuals()
		return

	# (Logic remains the same, but implicitly uses current_tree_layout via helper funcs)
	# ... rest of update_visuals ...
	# Update Node Appearance
	for node_id in passive_nodes:
		var node = passive_nodes[node_id]
		if node_id == "start":
			node.modulate = NORMAL_COLOR
			node.disabled = true
			continue
		if active_passives.has(node_id):
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

	# Update Line Appearance
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
	if current_tree_layout.is_empty(): return # Don't process clicks if no layout

	if passive_id == "start": return

	var changed = false
	if active_passives.has(passive_id):
		_deactivate_node_and_dependents(passive_id)
		changed = true
	else:
		if _can_activate_node(passive_id):
			print("Activating node: ", passive_id)
			active_passives[passive_id] = true
			changed = true
		else:
			printerr("Attempted to press node '%s' that cannot be activated!" % passive_id)

	if changed:
		update_visuals()
		# IMPORTANT: Update GlobalPassive with the new state
		GlobalPassive.player_passive_tree = active_passives.duplicate()
		emit_signal("passive_tree_changed", active_passives) # Signal potentially redundant if GlobalPassive is source of truth?
			
func _on_background_gui_input(event: InputEvent):
	# (Dragging and Zooming logic remains the same)
	# ...
	if event is InputEventMouseButton:
		# --- Dragging Logic ---
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_mouse_position = get_global_mouse_position()
				drag_start_container_position = tree_container.position
				accept_event()
			else:
				is_dragging = false
				accept_event()

		# --- Zooming Logic ---
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed: # Scroll events are typically reported as pressed
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
	if current_tree_layout.is_empty() or not current_tree_layout.has(node_id): return false # Check layout loaded
	if active_passives.has(node_id): return false
	if node_id == "start": return false

	# Check nodes connected directly from 'start'
	if current_tree_layout.has("start"):
		var start_node_data = current_tree_layout["start"]
		var start_connections = start_node_data.get("connections", [])
		if typeof(start_connections) == TYPE_ARRAY and start_connections.has(node_id):
			return active_passives.has("start")

	# Check other nodes: requires at least one active *direct* prerequisite
	for potential_prereq_id in current_tree_layout:
		var prereq_data = current_tree_layout[potential_prereq_id]
		var connections = prereq_data.get("connections", [])
		if typeof(connections) == TYPE_ARRAY and connections.has(node_id):
			if active_passives.has(potential_prereq_id):
				return true
	return false

	
func _has_active_prerequisite(node_id: String) -> bool:
	if current_tree_layout.is_empty() or not current_tree_layout.has(node_id): return false # Check layout loaded
	if node_id == "start": return false

	if current_tree_layout.has("start"):
		var start_node_data = current_tree_layout["start"]
		var start_connections = start_node_data.get("connections", [])
		if typeof(start_connections) == TYPE_ARRAY and start_connections.has(node_id):
			return active_passives.has("start")

	for potential_prereq_id in current_tree_layout:
		var prereq_data = current_tree_layout[potential_prereq_id]
		var connections = prereq_data.get("connections", [])
		if typeof(connections) == TYPE_ARRAY and connections.has(node_id):
			if active_passives.has(potential_prereq_id):
				return true
	return false
	
func _deactivate_node_and_dependents(node_id_to_deactivate: String):
	if current_tree_layout.is_empty(): return # Check layout loaded
	if node_id_to_deactivate == "start":
		printerr("Cannot deactivate the start node.")
		return
	if not active_passives.has(node_id_to_deactivate): return

	print("Deactivating node: ", node_id_to_deactivate)
	active_passives.erase(node_id_to_deactivate)

	if current_tree_layout.has(node_id_to_deactivate):
		var node_data = current_tree_layout[node_id_to_deactivate]
		var connections = node_data.get("connections", [])
		if typeof(connections) == TYPE_ARRAY:
			for child_id in connections:
				if typeof(child_id) == TYPE_STRING and active_passives.has(child_id):
					if not _has_active_prerequisite(child_id):
						_deactivate_node_and_dependents(child_id)
	
