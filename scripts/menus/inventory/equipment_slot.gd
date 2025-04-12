extends Panel

signal item_equipped(item_data, slot_type)
signal item_unequipped(item_data, slot_type)

var base_slot_type = "none"
var slot_type = "none"

var item_data = null

@onready var item_texture_rect: TextureRect = $ItemTexture if has_node("ItemTexture") else null

var highlight_style = null
var default_style = null

func _ready():
	set_meta("is_equipment_slot", true)

	default_style = get_theme_stylebox("panel", "Panel")

	var n = name.to_lower()
	if "weapon" in n: base_slot_type = "weapon"
	elif "shield" in n: base_slot_type = "shield"
	elif "helmet" in n: base_slot_type = "helmet"
	elif "armor" in n or "armour" in n: base_slot_type = "armor"
	elif "gloves" in n: base_slot_type = "gloves"
	elif "boots" in n: base_slot_type = "boots"
	elif "belt" in n: base_slot_type = "belt"
	elif "ring" in n: base_slot_type = "ring"
	elif "amulet" in n: base_slot_type = "amulet"
	else: print("Warning: Could not determine slot type for: ", name)

	slot_type = base_slot_type

	if default_style:
		highlight_style = default_style.duplicate()
		highlight_style.border_color = Color(0.9, 0.7, 0.1, 1)
		highlight_style.border_width_bottom = 3
		highlight_style.border_width_top = 3
		highlight_style.border_width_left = 3
		highlight_style.border_width_right = 3
	else:
		printerr("EquipmentSlot ", name, ": Could not get default panel stylebox.")
		highlight_style = StyleBoxFlat.new()
		highlight_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
		highlight_style.border_color = Color(0.9, 0.7, 0.1, 1)
		highlight_style.border_width_left = 3
		highlight_style.border_width_top = 3
		highlight_style.border_width_right = 3
		highlight_style.border_width_bottom = 3
		highlight_style.corner_radius_top_left = 4
		highlight_style.corner_radius_top_right = 4
		highlight_style.corner_radius_bottom_right = 4
		highlight_style.corner_radius_bottom_left = 4

	if not has_node("ItemTexture"):
		print("EquipmentSlot ", name, ": Creating ItemTexture node dynamically.")
		item_texture_rect = TextureRect.new()
		item_texture_rect.name = "ItemTexture"
		item_texture_rect.layout_mode = LayoutMode.ANCHORS
		item_texture_rect.anchor_right = 1.0
		item_texture_rect.anchor_bottom = 1.0
		item_texture_rect.expand_mode = TextureRect.ExpandMode.IGNORE_SIZE
		item_texture_rect.stretch_mode = TextureRect.StretchMode.KEEP_ASPECT_CENTERED
		item_texture_rect.mouse_filter = Control.MouseFilter.IGNORE
		add_child(item_texture_rect)
	else:
		item_texture_rect = $ItemTexture
		item_texture_rect.mouse_filter = Control.MouseFilter.IGNORE

	unhighlight()

func get_slot_type() -> String:
	return slot_type

func get_item_data() -> Dictionary:
	return item_data


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if item_data != null:
				var drag_data = {
					"origin": "equipment",
					"item_data": item_data,
					"slot_type": slot_type,
					"source_node": self,
				}

				var preview = TextureRect.new()
				if is_instance_valid(item_texture_rect) and item_texture_rect.texture:
					preview.texture = item_texture_rect.texture
					var item_size_px = item_data.get("size", Vector2i(1,1)) * 64
					preview.custom_minimum_size = Vector2(item_size_px.x, item_size_px.y)
					preview.expand_mode = TextureRect.ExpandMode.IGNORE_SIZE
					preview.stretch_mode = item_texture_rect.stretch_mode
				else:
					preview.custom_minimum_size = Vector2(64, 64)

				set_drag_preview(preview)
				get_viewport().gui_set_drag_data(drag_data)


		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if item_data != null:
				print("Right-click detected on slot: ", name, " with item: ", item_data.get("name"))
				unequip_item()


func _can_drop_data(_pos, data) -> bool:
	if not data is Dictionary or not data.has("item_data"):
		return false

	var incoming_item_data = data["item_data"]
	var required_equip_type = incoming_item_data.get("equip_type", "none")

	var can_equip = (required_equip_type == base_slot_type)

	if base_slot_type == "ring" and required_equip_type == "ring":
		can_equip = true

	if can_equip:
		highlight()
	#else: # Don't unhighlight here, mouse exit handles it
		#unhighlight()

	return can_equip

func _drop_data(_pos, data):
	unhighlight()

	if not data is Dictionary or not data.has("item_data"):
		printerr("EquipmentSlot ", name, ": Invalid data dropped.")
		return

	var incoming_item_data = data["item_data"]
	var origin = data.get("origin", "unknown")
	var source_node = data.get("source_node", null)

	print("EquipmentSlot ", name, ": Attempting drop of '", incoming_item_data.get("name"), "' from '", origin, "'")

	var item_to_swap_out = item_data

	set_item(incoming_item_data)
	emit_signal("item_equipped", incoming_item_data, slot_type)

	if origin == "grid":
		if is_instance_valid(source_node) and source_node is InventoryItem:
			var inventory_grid = source_node.inventory_grid
			if is_instance_valid(inventory_grid) and inventory_grid.has_method("remove_item"):
				inventory_grid.remove_item(source_node)
				print("Removed dropped item from grid.")

				if item_to_swap_out != null:
					print("Trying to place swapped item '", item_to_swap_out.get("name"), "' back onto grid.")
					var target_pos = inventory_grid.find_empty_space_for(item_to_swap_out)
					if target_pos != Vector2i(-1, -1):
						if not inventory_grid.add_item(item_to_swap_out, target_pos):
							printerr("EquipmentSlot ", name, ": Failed to place swapped item back on grid!")
							# TODO: Handle this error - drop item on ground? Temp stash?
					else:
						printerr("EquipmentSlot ", name, ": No space on grid for swapped item!")
						# TODO: Handle this error
			else:
				printerr("EquipmentSlot ", name, ": Could not get valid grid reference or remove_item method from source.")
		else:
			printerr("EquipmentSlot ", name, ": Invalid source_node for grid origin drop.")

	elif origin == "equipment":
		if is_instance_valid(source_node) and source_node.has_method("set_item"):
			var other_slot_script = source_node
			if item_to_swap_out != null:
				other_slot_script.set_item(item_to_swap_out)
				other_slot_script.emit_signal("item_equipped", item_to_swap_out, other_slot_script.slot_type)
				print("Swapped '", item_to_swap_out.get("name"), "' into slot ", other_slot_script.name)
			else:
				other_slot_script.clear_item()
				print("Cleared source slot ", other_slot_script.name, " after move.")
		else:
			printerr("EquipmentSlot ", name, ": Invalid source_node for equipment origin drop.")

	else:
		printerr("EquipmentSlot ", name, ": Unknown drag origin '", origin, "'")


func set_item(new_item_data: Dictionary):
	if new_item_data == item_data:
		return

	item_data = new_item_data

	if not is_instance_valid(item_texture_rect):
		printerr("EquipmentSlot ", name, ": ItemTextureRect is not valid in set_item.")
		return

	if item_data and item_data.has("texture_path"):
		var texture = load(item_data["texture_path"])
		if texture:
			item_texture_rect.texture = texture
			item_texture_rect.visible = true
			tooltip_text = item_data.get("name", "Item") + "\n" + item_data.get("description", "")
		else:
			printerr("EquipmentSlot ", name, ": Failed to load texture: ", item_data["texture_path"])
			item_texture_rect.texture = null
			item_texture_rect.visible = false
			tooltip_text = ""
	else:
		item_texture_rect.texture = null
		item_texture_rect.visible = false
		tooltip_text = base_slot_type.capitalize()


func clear_item():
	if item_data == null: return

	var old_item_data = item_data
	item_data = null

	if is_instance_valid(item_texture_rect):
		item_texture_rect.texture = null
		item_texture_rect.visible = false

	tooltip_text = base_slot_type.capitalize()
	emit_signal("item_unequipped", old_item_data, slot_type)
	print("Cleared item from slot: ", name)


func unequip_item():
	var inventory_node = get_node_or_null("/root/Game/UI/Inventory")
	if !inventory_node: 
		var camera = get_viewport().get_camera_2d()
		if camera:
			inventory_node = camera.get_node_or_null("Inventory")

	if inventory_node and inventory_node.has_method("unequip_item"):
		inventory_node.unequip_item(self) 
	else:
		printerr("EquipmentSlot ", name, ": Could not find Inventory node or 'unequip_item' method. Check node path.")

func highlight():
	if highlight_style:
		add_theme_stylebox_override("panel", highlight_style)
	else:
		print("WARN: No highlight style for slot ", name)

func unhighlight():
	if default_style:
		add_theme_stylebox_override("panel", default_style)
	else:
		remove_theme_stylebox_override("panel")


func _on_mouse_entered():
	pass

func _on_mouse_exited():
	unhighlight()
