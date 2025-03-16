extends CharacterBody2D

class_name GameNPC

@export_multiline var dialog_text: String = "Hello there!"
@export var npc_name: String = "Villager"
@export var npc_color: Color = Color(0.31802, 0.31802, 0.31802, 1)
@export var interaction_radius: float = 60.0
@export var can_move: bool = false
@export var movement_speed: float = 40.0
@export var movement_range: float = 100.0
@export var idle_time_range: Vector2 = Vector2(2.0, 5.0)  # Min and max idle time

var player_in_range: bool = false
var dialog_box = null
var initial_position: Vector2
var target_position: Vector2
var is_idle: bool = true
var idle_timer: float = 0.0
var current_idle_time: float = 3.0

func _ready():
	# Set the NPC color
	$ColorRect.color = npc_color
	
	# Store initial position for wandering behavior
	initial_position = global_position
	target_position = global_position
	
	# Find the dialog box in the scene
	await get_tree().process_frame
	dialog_box = get_tree().get_first_node_in_group("dialog_box")
	
	# Set up randomized idle time
	randomize()
	set_new_idle_time()

func _process(delta):
	if can_move:
		handle_movement(delta)

func handle_movement(delta):
	if is_idle:
		idle_timer += delta
		if idle_timer >= current_idle_time:
			is_idle = false
			set_new_target_position()
	else:
		var direction = (target_position - global_position).normalized()
		if global_position.distance_to(target_position) > 5:
			velocity = direction * movement_speed
			move_and_slide()
		else:
			is_idle = true
			idle_timer = 0
			set_new_idle_time()

func set_new_target_position():
	var random_offset = Vector2(
		randf_range(-movement_range, movement_range),
		randf_range(-movement_range, movement_range)
	)
	target_position = initial_position + random_offset

func set_new_idle_time():
	current_idle_time = randf_range(idle_time_range.x, idle_time_range.y)

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		if dialog_box != null:
			dialog_box.show_dialog(npc_name, dialog_text)

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		if dialog_box != null:
			dialog_box.hide_dialog()
