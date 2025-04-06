extends CharacterBody2D

signal player_died

@export var speed = 300

var mouse_target = null
var can_move = true
var sword_scene = preload("res://scenes/weapons/sword.tscn")
var sword = null
var is_following_mouse = false
var current_building = null 

func _ready():
	$HitArea.body_entered.connect(_on_hitbox_body_entered)
	$ColorRect.color = Color.BLUE
	set_process_input(true)
	add_to_group("player")

	sword = sword_scene.instantiate()
	sword.position = Vector2(30, 0)
	add_child(sword)

func _physics_process(delta):
	if can_move:
		if PlayerData.get_health() < PlayerData.get_calculated_max_heath():
			var health_to_regen = PlayerData.get_health_regen_rate() * delta
			PlayerData.set_health(PlayerData.get_health() + health_to_regen)

		# Mana Regen
		if PlayerData.get_mana() < PlayerData.get_calculated_max_mana():
			var mana_to_regen = PlayerData.get_mana_regen_rate() * delta
			PlayerData.set_mana(PlayerData.get_mana() + mana_to_regen)
	
	if can_move:
		if is_following_mouse:
			mouse_target = get_global_mouse_position()

		var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

		if mouse_target:
			input_vector = global_position.direction_to(mouse_target)

			if global_position.distance_to(mouse_target) < 10:
				input_vector = Vector2.ZERO
				if not is_following_mouse:
					mouse_target = null

		velocity = input_vector * speed
		move_and_slide()

		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down") or mouse_target:
			update_sword_direction()
	else:
		velocity = Vector2.ZERO


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_following_mouse = true
				mouse_target = get_global_mouse_position()
			else:
				is_following_mouse = false

		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if sword and can_move:
				if use_mana(10):
					sword.swing()

	elif event is InputEventMouseMotion and is_following_mouse:
		mouse_target = get_global_mouse_position()

	elif event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE and current_building:
			exit_building()

func lock_movement():
	can_move = false
	velocity = Vector2.ZERO
	mouse_target = null
	is_following_mouse = false
	
func unlock_movement():
	can_move = true

func update_sword_direction():
	if sword:
		var mouse_pos = get_global_mouse_position()
		var direction = global_position.direction_to(mouse_pos)
		sword.position = direction * 30
		if direction.x < 0: sword.scale.y = -1
		else: sword.scale.y = 1

func enter_building(building):
	current_building = building

func exit_building():
	if current_building:
		current_building.toggle_building_entry()
		current_building = null

func _on_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		take_damage(10)

func take_damage(amount: float):
	var current_hp = PlayerData.get_health()
	PlayerData.set_health(current_hp - amount)

	if PlayerData.get_health() <= 0:
		die()

func heal(amount: float):
	var current_hp = PlayerData.get_health()
	PlayerData.set_health(current_hp + amount)

func use_mana(amount: float) -> bool:
	if PlayerData.get_mana() >= amount:
		PlayerData.set_mana(PlayerData.get_mana() - amount)
		return true
	return false

func die():
	print("Player Died!")
	lock_movement()
	emit_signal("player_died")
