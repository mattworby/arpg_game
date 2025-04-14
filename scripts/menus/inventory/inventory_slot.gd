extends Panel

var slot_id = -1

signal item_equipped(item_id)
signal item_unequipped(item_id)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP

func can_accept_item(item_data):
	if item_data.has("valid_slots") and item_data.valid_slots.has(slot_id):
		return true
	return false

func set_highlighted(highlight):
	if highlight:
		modulate = Color(1.2, 1.2, 1.2)
	else:
		modulate = Color(1, 1, 1)
