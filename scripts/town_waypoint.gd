extends Area2D

class_name TravelWaypoint

signal waypoint_activated

@export var waypoint_radius: float = 30.0
@export var waypoint_color: Color = Color(0.2, 0.4, 0.8, 0.7)
@export var highlight_color: Color = Color(0.3, 0.6, 1.0, 0.8)
@export var pulse_speed: float = 2.0
@export var pulse_amount: float = 0.2

var player_in_range: bool = false
var is_highlighted: bool = false
var original_scale: Vector2
var travel_menu = null
var player_locked: bool = false
var player_ref = null
var available_destinations = [
	{
		"name": "Forest Path",
		"scene_path": "res://scenes/first_area/basic_level.tscn",
		"icon": "res://assets/icons/forest_icon.png"
	},
	{
		"name": "Mountain Pass",
		"scene_path": "res://scenes/mountain_scene.tscn",
		"icon": "res://assets/icons/mountain_icon.png"
	},
	{
		"name": "River Crossing",
		"scene_path": "res://scenes/river_scene.tscn",
		"icon": "res://assets/icons/river_icon.png"
	}
]

func _ready():
	# Create the visual circle
	var circle = CircleShape2D.new()
	circle.radius = waypoint_radius
	
	var collision = CollisionShape2D.new()
	collision.shape = circle
	add_child(collision)
	
	# Create waypoint visual
	var waypoint_visual = ColorRect.new()
	waypoint_visual.size = Vector2(waypoint_radius * 2, waypoint_radius * 2)
	waypoint_visual.position = Vector2(-waypoint_radius, -waypoint_radius)
	waypoint_visual.color = waypoint_color
	waypoint_visual.name = "WaypointVisual"
	add_child(waypoint_visual)
	
	# Make it circular
	var style = StyleBoxFlat.new()
	style.bg_color = waypoint_color
	style.corner_radius_top_left = waypoint_radius
	style.corner_radius_top_right = waypoint_radius
	style.corner_radius_bottom_left = waypoint_radius
	style.corner_radius_bottom_right = waypoint_radius
	waypoint_visual.add_theme_stylebox_override("panel", style)
	
	# Save original scale for pulsing effect
	original_scale = Vector2(1, 1)
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Create Travel Menu
	create_travel_menu()
	
func _process(delta):
	if is_highlighted:
		# Create pulsing effect
		var pulse = sin(Time.get_ticks_msec() * 0.001 * pulse_speed) * pulse_amount + 1.0
		scale = original_scale * pulse
		
		var visual = get_node("WaypointVisual")
		if visual:
			visual.color = highlight_color
	else:
		scale = original_scale
		var visual = get_node("WaypointVisual")
		if visual:
			visual.color = waypoint_color

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_highlighted:
		# Find player using get_tree()
		var player = get_tree().get_nodes_in_group("player")[0]
		if player:
			player.mouse_target = global_position
			print("Player moving to waypoint")

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		show_travel_menu()
		lock_player()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		player_ref = null
		hide_travel_menu()
		unlock_player()

func _on_mouse_entered():
	is_highlighted = true

func _on_mouse_exited():
	is_highlighted = false

func lock_player():
	if player_ref:
		# Store the player's previous state if needed
		player_locked = true
		
		if player_ref.has_method("lock_movement"):
			player_ref.lock_movement()
		else:
			# Fallback if lock_movement doesn't exist
			# Store velocity and disable processing
			player_ref.set_process(false)
			player_ref.set_physics_process(false)
			if player_ref is CharacterBody2D:
				player_ref.velocity = Vector2.ZERO

func unlock_player():
	if player_ref and player_locked:
		player_locked = false
		
		if player_ref.has_method("unlock_movement"):
			player_ref.unlock_movement()
		else:
			# Fallback if unlock_movement doesn't exist
			player_ref.set_process(true)
			player_ref.set_physics_process(true)

func create_travel_menu():
	travel_menu = CanvasLayer.new()
	travel_menu.layer = 10
	add_child(travel_menu)
	
	var panel = Panel.new()
	panel.name = "TravelPanel"
	panel.size = Vector2(300, 400)
	panel.position = Vector2(512 - 150, 100)
	panel.visible = false
	travel_menu.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.name = "DestinationsList"
	vbox.position = Vector2(10, 50)
	vbox.size = Vector2(280, 340)
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "Travel Destinations"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(10, 10)
	title.size = Vector2(280, 30)
	panel.add_child(title)
	
	for destination in available_destinations:
		add_destination_button(vbox, destination)
	
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.position = Vector2(100, 360)
	close_button.size = Vector2(100, 30)
	panel.add_child(close_button)
	
	close_button.pressed.connect(hide_travel_menu)

func add_destination_button(container, destination_data):
	var button = Button.new()
	button.text = destination_data.name
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 60)
	container.add_child(button)
	
	# Store destination data in button metadata
	button.set_meta("destination", destination_data)
	
	# Connect button press signal
	button.pressed.connect(func(): travel_to_destination(destination_data))

func travel_to_destination(destination):
	print("Traveling to: " + destination.name)
	get_tree().change_scene_to_file(destination.scene_path)

func show_travel_menu():
	if travel_menu and travel_menu.has_node("TravelPanel"):
		travel_menu.get_node("TravelPanel").visible = true
		
		# Emit signal that others can connect to
		emit_signal("waypoint_activated")

func hide_travel_menu():
	if travel_menu and travel_menu.has_node("TravelPanel"):
		travel_menu.get_node("TravelPanel").visible = false
		unlock_player()
