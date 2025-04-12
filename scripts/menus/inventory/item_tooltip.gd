extends Panel

func _ready():
	visible = false

func update_content(item_data):
	$VBoxContainer/ItemName.text = item_data.name
	
	$VBoxContainer/ItemType.text = item_data.type.capitalize()
	
	for child in $VBoxContainer/StatsContainer.get_children():
		child.queue_free()
	
	if item_data.has("stats"):
		for stat_name in item_data.stats:
			var stat_value = item_data.stats[stat_name]
			var stat_label = Label.new()
			stat_label.text = stat_name.capitalize() + ": " + str(stat_value)
			$VBoxContainer/StatsContainer.add_child(stat_label)
	
	await get_tree().process_frame
	custom_minimum_size = $VBoxContainer.size + Vector2(20, 20)
