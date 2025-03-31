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
	for child in tree_container.get_children():
		child.queue_free()

	passive_nodes.clear()
	connection_lines.clear()

	var positions = {
		"start": Vector2(200, 300),
		"strength": Vector2(350, 300)
	}

	var start_data = PASSIVE_DATABASE.get_passive("start")
	if start_data:
		var start_node = _create_passive_node("start", start_data, positions["start"])
		start_node.disabled = true
		start_node.modulate = NORMAL_COLOR
		tree_container.add_child(start_node)
		passive_nodes["start"] = start_node

	var strength_data = PASSIVE_DATABASE.get_passive("strength")
	if strength_data:
		var strength_node = _create_passive_node("strength", strength_data, positions["strength"])
		strength_node.pressed.connect(_on_passive_node_pressed.bind("strength"))
		tree_container.add_child(strength_node)
		passive_nodes["strength"] = strength_node


	var line_start_strength = _create_connection_line("start", "strength", positions["start"], positions["strength"])
	tree_container.add_child(line_start_strength)
	line_start_strength.z_index = -1 
	connection_lines["start-strength"] = line_start_strength

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
	for passive_id in passive_nodes:
		var node = passive_nodes[passive_id]
		if active_passives.has(passive_id):
			node.modulate = NORMAL_COLOR
			if passive_id != "start":
				node.disabled = true
		else:
			var can_activate = false
			if passive_id == "strength" and active_passives.has("start"):
					can_activate = true
			# Add more complex prerequisite checks here for a larger tree

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

		if active_passives.has(from_id) and active_passives.has(to_id):
			line.default_color = LINE_ACTIVE_COLOR
		else:
			line.default_color = LINE_INACTIVE_COLOR


func _on_passive_node_pressed(passive_id: String):
	print("Node pressed: ", passive_id)
	if !active_passives.has(passive_id):
		var can_activate = false
		if passive_id == "strength" and active_passives.has("start"):
			can_activate = true
		# Add more checks for other nodes...

		if can_activate:
			print("Activating node: ", passive_id)
			active_passives[passive_id] = true

			update_visuals()

			emit_signal("passive_tree_changed", active_passives)
		else:
			print("Cannot activate node yet: ", passive_id)
			
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
