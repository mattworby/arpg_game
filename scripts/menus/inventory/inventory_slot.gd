extends Panel

# ID for this slot
var slot_id = -1

# Signal when item is equipped/unequipped
signal item_equipped(item_id)
signal item_unequipped(item_id)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP

func can_accept_item(item_data):
	# Check if this item can be equipped in this slot
	if item_data.has("valid_slots") and item_data.valid_slots.has(slot_id):
		return true
	return false

func set_highlighted(highlight):
	if highlight:
		modulate = Color(1.2, 1.2, 1.2)
	else:
		modulate = Color(1, 1, 1)