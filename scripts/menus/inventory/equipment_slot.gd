# equipment_slot.gd
extends Panel

signal item_equipped(item_data, slot_type)
signal item_unequipped(item_data, slot_type)

var slot_type = "none"
var item_data = null
var item_texture = null
var highlight_style = null
var default_style = null

func _ready():
	# Store the default panel style
	default_style = get_theme_stylebox("panel")
	
	# Determine slot type based on node name
	if name.contains("Weapon"):
		slot_type = "weapon"
	elif name.contains("Shield"):
		slot_type = "shield"
	elif name.contains("Helmet"):
		slot_type = "helmet"
	elif name.contains("Armor"):
		slot_type = "armor"
	elif name.contains("Gloves"):
		slot_type = "gloves"
	elif name.contains("Boots"):
		slot_type = "boots"
	elif name.contains("Belt"):
		slot_type = "belt"
	elif name.contains("Ring"):
		slot_type = "ring"
	elif name.contains("Amulet"):
		slot_type = "amulet"
	
	# Create a highlighted style variant
	highlight_style = default_style.duplicate()
	highlight_style.border_color = Color(0.9, 0.7, 0.1)
	highlight_style.border_width_bottom = 2
	highlight_style.border_width_top = 2
	highlight_style.border_width_left = 2
	highlight_style.border_width_right = 2

func _gui_input(event):
	# Handle mouse events
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Start dragging from equipment slot if it has an item
			if item_data != null:
				var drag_data = {
					"origin": "equipment",
					"item_data": item_data,
					"slot_type": slot_type,
					"node": self,
				}
				
				# Set drag preview
				var preview = TextureRect.new()
				preview.texture = item_texture
				preview.size = Vector2(64, 64)
				set_drag_preview(preview)
				
				# Start the drag operation
				set_drag_data(drag_data)
		
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Right-click to unequip
			if item_data != null:
				unequip_item()

func set_drag_data(data):
	get_viewport().set_input_as_handled()
	get_viewport().gui_release_focus()
	get_viewport().set_drag_data(data)

func can_drop_data(_pos, data):
	# Check if this slot can accept the dragged item
	if data is Dictionary and data.has("item_data"):
		# Check if the item's equipment type matches this slot
		var item = data["item_data"]
		if item.has("equip_type") and item["equip_type"] == slot_type:
			return true
		
		# Special case for rings (can go in either ring slot)
		if slot_type == "ring" and item.has("equip_type") and item["equip_type"] == "ring":
			return true
	
	return false

func drop_data(_pos, data):
	# Handle dropping an item into this equipment slot
	if data is Dictionary and data.has("item_data"):
		var current_item = item_data
		
		# If we already have an item, we'll swap it with the dragged item
		if current_item != null:
			# If drag came from inventory, swap with that slot
			if data.has("origin") and data["origin"] == "inventory" and data.has("node"):
				var inventory_slot = data["node"]
				inventory_slot.set_item(current_item)
			
			# If drag came from another equipment slot, swap with that slot
			elif data.has("origin") and data["origin"] == "equipment" and data.has("node"):
				var other_equip_slot = data["node"]
				other_equip_slot.set_item(current_item)
		else:
			# If drag came from inventory, clear that slot
			if data.has("origin") and data["origin"] == "inventory" and data.has("node"):
				var inventory_slot = data["node"]
				inventory_slot.clear_item()
			
			# If drag came from another equipment slot, clear that slot
			elif data.has("origin") and data["origin"] == "equipment" and data.has("node"):
				var other_equip_slot = data["node"]
				other_equip_slot.clear_item()
		
		# Set the dragged item in this slot
		set_item(data["item_data"])
		
		# Emit signal that item was equipped
		emit_signal("item_equipped", data["item_data"], slot_type)

func set_item(item):
	item_data = item
	
	# Create and add TextureRect to display the item
	if has_node("ItemTexture"):
		$ItemTexture.queue_free()
	
	var texture_rect = TextureRect.new()
	texture_rect.name = "ItemTexture"
	texture_rect.expand = true
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.size = size
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Load the texture from the item data
	if item and item.has("texture_path"):
		var texture = load(item["texture_path"])
		if texture:
			texture_rect.texture = texture
			item_texture = texture
	
	add_child(texture_rect)

func clear_item():
	item_data = null
	
	# Remove the texture
	if has_node("ItemTexture"):
		$ItemTexture.queue_free()
	
	emit_signal("item_unequipped", item_data, slot_type)

func unequip_item():
	# Tell parent inventory to handle moving this item to inventory
	var inventory = get_parent().get_parent().get_parent()
	if inventory.has_method("unequip_item"):
		inventory.unequip_item(self)

func highlight():
	add_theme_stylebox_override("panel", highlight_style)

func unhighlight():
	add_theme_stylebox_override("panel", default_style)