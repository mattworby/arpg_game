extends Node

var current_room: int = 1
var player_instance = null 
var player_body: CharacterBody2D = null 
var player_inventory: Control = null 
var current_level_instance: Node = null
var current_room_generator: RoomGenerator = null

@export var item_drop_chance_percent: float = 100.0

var ui_room_counter: Label = null
var ui_player_health: Label = null
var ui_game_over_screen: Control = null
var ui_rooms_reached_label: Label = null
var last_item_instance_id: int = 0

const DROPPED_ITEM_HOVER_MODULATE = Color(0.8, 0.8, 0.8, 1.0)
const DROPPED_ITEM_NORMAL_MODULATE = Color(1.0, 1.0, 1.0, 1.0)

func _ready():
	print("GameManager Ready.")

func register_level(level_node: Node):
	print("GameManager: Registering level: ", level_node.name)
	current_level_instance = level_node
	ui_room_counter = level_node.find_child("RoomCounter", true, false) 
	ui_player_health = level_node.find_child("HealthLabel", true, false)
	ui_game_over_screen = level_node.find_child("GameOverScreen", true, false)
	ui_rooms_reached_label = level_node.find_child("RoomsReachedLabel", true, false)

	if not ui_room_counter: push_warning("GameManager: UI RoomCounter not found in registered level.")
	if not ui_player_health: push_warning("GameManager: UI HealthLabel not found in registered level.")
	if not ui_game_over_screen: push_warning("GameManager: UI GameOverScreen not found in registered level.")
	if not ui_rooms_reached_label: push_warning("GameManager: UI RoomsReachedLabel not found in registered level.")

	current_room_generator = level_node.find_child("RoomGeneratorInstance", false)
	if is_instance_valid(current_room_generator):
		if not current_room_generator.is_connected("room_cleared", Callable(self, "_on_room_cleared")):
			current_room_generator.room_cleared.connect(_on_room_cleared)
	else:
		push_warning("GameManager: Could not find RoomGeneratorInstance in registered level.")

	update_room_display()

func register_player(p_instance, p_body):
	print("GameManager: Registering player.")
	player_instance = p_instance
	player_body = p_body
	
	print(GlobalInventory.has_method("get_inventory_node"))
	
	if GlobalInventory.has_method("get_inventory_node"):
		player_inventory = GlobalInventory.get_inventory_node()
		if not is_instance_valid(player_inventory):
			printerr("GameManager Error: GlobalInventory returned an invalid inventory node.")
		else:
			print("GameManager: Successfully got player inventory reference from GlobalInventory.")
	else:
		printerr("GameManager Error: GlobalInventory singleton or get_inventory_node method not found!")

	if is_instance_valid(player_body):
		if player_body.has_signal("health_changed"):
			if not player_body.is_connected("health_changed", Callable(self, "update_player_health")):
				player_body.health_changed.connect(update_player_health)
		else:
			push_warning("GameManager: Registered player body lacks 'health_changed' signal.")

		if player_body.has_signal("player_died"):
			if not player_body.is_connected("player_died", Callable(self, "handle_player_death")):
				player_body.player_died.connect(handle_player_death)
		else:
			push_warning("GameManager: Registered player body lacks 'player_died' signal.")
	else:
		push_error("GameManager: Invalid player body provided during registration.")

func unregister_level():
	print("GameManager: Unregistering level.")
	if is_instance_valid(current_room_generator):
		if current_room_generator.is_connected("room_cleared", Callable(self, "_on_room_cleared")):
			current_room_generator.disconnect("room_cleared", Callable(self, "_on_room_cleared"))

	current_level_instance = null
	current_room_generator = null
	ui_room_counter = null
	ui_player_health = null
	ui_game_over_screen = null
	ui_rooms_reached_label = null

func update_player_health(current_health, max_health):
	if is_instance_valid(ui_player_health):
		ui_player_health.text = "Health: " + str(current_health) + "/" + str(max_health)

func handle_player_death():
	print("GameManager: Player Died!")
	if is_instance_valid(ui_game_over_screen):
		if is_instance_valid(ui_rooms_reached_label):
			ui_rooms_reached_label.text = "Rooms reached: " + str(current_room)
		ui_game_over_screen.visible = true
	else:
		push_warning("GameManager: Cannot show Game Over screen - UI reference missing.")

func handle_enemy_death(enemy_body_node: CharacterBody2D, level_node: Node):
	if not is_instance_valid(enemy_body_node) or not is_instance_valid(level_node):
		print("GameManager: Received enemy_died signal with invalid nodes.")
		return
	if level_node != current_level_instance:
		print("GameManager: Received enemy death signal for a level that isn't registered as current.")
		return

	var enemy_root_node = enemy_body_node.get_parent()
	if not is_instance_valid(enemy_root_node): return

	print("GameManager: Enemy %s died in level %s. Handling drops..." % [enemy_root_node.name, level_node.name])

	var items_to_drop = floor(item_drop_chance_percent / 100.0 + randf())
	print("GameManager: Attempting to drop %d items." % items_to_drop)

	for i in range(items_to_drop):
		var base_ids = BaseItems.get_all_base_ids()
		if base_ids.is_empty(): continue
		var random_base_id = base_ids.pick_random()

		var enemy_lvl = 1
		var potential_level = enemy_body_node.get("level")
		if potential_level != null and potential_level is int and potential_level > 0:
			enemy_lvl = potential_level

		var generated_item = ItemGenerator.generate_item(random_base_id, enemy_lvl)
		if generated_item.is_empty(): continue
		
		last_item_instance_id += 1
		var item_instance_id = "item_instance_%d" % last_item_instance_id
		generated_item["instance_id"] = item_instance_id

		var item_label_panel = PanelContainer.new()
		var item_label = Label.new()
		item_label.text = generated_item.display_name
		item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		item_label.add_theme_color_override("font_color", Color.BLACK)
		item_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		item_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		item_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		item_label_panel.add_child(item_label)

		var style = StyleBoxFlat.new()
		style.bg_color = generated_item.tooltip_color
		style.content_margin_left = 5; style.content_margin_right = 5
		style.content_margin_top = 2; style.content_margin_bottom = 2
		item_label_panel.add_theme_stylebox_override("panel", style)
		
		item_label_panel.set_meta("item_data", generated_item)
		item_label_panel.mouse_filter = Control.MOUSE_FILTER_STOP

		var err1 = item_label_panel.connect("mouse_entered", Callable(self, "_on_dropped_item_mouse_entered").bind(item_label_panel))
		var err2 = item_label_panel.connect("mouse_exited", Callable(self, "_on_dropped_item_mouse_exited").bind(item_label_panel))
		var err3 = item_label_panel.connect("gui_input", Callable(self, "_on_dropped_item_gui_input").bind(item_label_panel))

		print("DEBUG GameManager: Connecting signals for ", generated_item.instance_id)
		if err1 != OK: printerr("  ERROR connecting mouse_entered: ", err1)
		if err2 != OK: printerr("  ERROR connecting mouse_exited: ", err2)
		if err3 != OK: printerr("  ERROR connecting gui_input: ", err3)

		var drop_position = enemy_body_node.global_position
		var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		item_label_panel.global_position = drop_position + offset

		var drop_container = level_node.get_dropped_items_container()
		if is_instance_valid(drop_container):
			drop_container.add_child(item_label_panel)
		else:
			push_warning("GameManager: Level %s has no valid dropped items container." % level_node.name)
			item_label_panel.queue_free()

	if is_instance_valid(current_room_generator):
		if current_room_generator.has_method("enemy_was_defeated"):
			current_room_generator.enemy_was_defeated(enemy_body_node)


func _on_room_cleared():
	if not is_instance_valid(current_level_instance):
		push_warning("GameManager: Received room_cleared signal, but no level is registered.")
		return

	print("GameManager: Room " + str(current_room) + " cleared! Advancing...")
	current_room += 1
	update_room_display()

	if current_level_instance.has_method("generate_next_room"):
		await get_tree().create_timer(1.0).timeout
		if is_instance_valid(current_level_instance):
			current_level_instance.generate_next_room()
		else:
			print("GameManager: Level became invalid during room transition delay.")
	else:
		push_warning("GameManager: Current level %s does not have generate_next_room() method." % current_level_instance.name)

func update_room_display():
	if is_instance_valid(ui_room_counter):
		ui_room_counter.text = "Room: " + str(current_room)

func restart_game():
	print("GameManager: Restarting game...")
	current_room = 1
	get_tree().reload_current_scene()

func go_to_main_menu():
	print("GameManager: Going to main menu...")
	unregister_level()
	current_room = 1
	player_instance = null
	player_body = null
	get_tree().change_scene_to_file("res://scenes/main_town/town_scene.tscn")

func _on_dropped_item_mouse_entered(label_panel: PanelContainer):
	if is_instance_valid(label_panel):
		label_panel.modulate = DROPPED_ITEM_HOVER_MODULATE

func _on_dropped_item_mouse_exited(label_panel: PanelContainer):
	if is_instance_valid(label_panel):
		label_panel.modulate = DROPPED_ITEM_NORMAL_MODULATE

func _on_dropped_item_gui_input(event: InputEvent, label_panel: PanelContainer):
	if not is_instance_valid(label_panel): return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("GameManager: Click detected on dropped item.")

		if not is_instance_valid(player_inventory):
			print("GameManager: Cannot pick up item - player inventory reference is missing.")
			return

		var item_data = label_panel.get_meta("item_data", null)
		if item_data == null or not item_data is Dictionary:
			printerr("GameManager: Failed to get valid item_data from clicked label's metadata!")
			label_panel.queue_free()
			return

		print("GameManager: Attempting to add item: %s" % item_data.get("instance_id", "NO_ID"))

		if player_inventory.has_method("add_generated_item"):
			var added_successfully = player_inventory.add_generated_item(item_data)

			if added_successfully:
				print("GameManager: Item added to inventory successfully.")
				label_panel.queue_free()
			else:
				print("GameManager: Failed to add item to inventory (likely no room).")
		else:
			printerr("GameManager: Player Inventory script is missing the 'add_generated_item' method!")
