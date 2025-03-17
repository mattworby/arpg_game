extends Area2D

@export var highlight_color: Color = Color(1, 1, 0, 0.5)
@export var exterior_scene_path: String = "res://scenes/main_town/town_scene.tscn"

var player_in_range: bool = false
var is_highlighted: bool = false
var highlight_rect: ColorRect
var can_exit = false

func _ready():
	var door_rect = $ColorRect
	
	highlight_rect = ColorRect.new()
	highlight_rect.size = door_rect.size
	highlight_rect.position = door_rect.position
	highlight_rect.color = highlight_color
	highlight_rect.visible = false
	add_child(highlight_rect)
	
	body_entered.connect(_on_exit_door_body_entered)
	mouse_entered.connect(_on_exit_door_mouse_entered)
	mouse_exited.connect(_on_exit_door_mouse_exited)
	
	set_process_input(true)
	
	await get_tree().create_timer(0.5).timeout
	can_exit = true

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_highlighted:
		# Find player using get_tree instead of absolute path
		var player = get_tree().get_nodes_in_group("player")[0]
		if player:
			player.mouse_target = global_position
			print("Player moving to exit door")

func _on_exit_door_body_entered(body):
	if body.is_in_group("player") and can_exit:
		print("Player entered exit door, returning to building: " + Global.current_building_name)
		player_in_range = true
		
		call_deferred("_change_scene")
		
func _change_scene():
	get_tree().change_scene_to_file(exterior_scene_path)

func _on_exit_door_mouse_entered():
	is_highlighted = true
	highlight_rect.visible = true
	print("Mouse hovering over exit door")

func _on_exit_door_mouse_exited():
	is_highlighted = false
	highlight_rect.visible = false
