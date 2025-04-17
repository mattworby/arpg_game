extends Panel

func _ready():
	visible = false

func update_content(item_data: Dictionary):
	if not item_data:
		printerr("Tooltip Error: Received null item_data.")
		visible = false
		return

	var display_name = item_data.get("display_name", "Unknown Item")
	$VBoxContainer/ItemName.text = display_name
	$VBoxContainer/ItemName.modulate = item_data.get("tooltip_color", Color.WHITE)

	var item_type_display = item_data.get("subtype", item_data.get("type", "Unknown")).capitalize()
	$VBoxContainer/ItemType.text = item_type_display

	for child in $VBoxContainer/StatsContainer.get_children():
		child.queue_free()

	if item_data.has("final_stats"):
		var stats_dict = item_data.final_stats
		if stats_dict.is_empty():
			pass
		else:
			for stat_name in stats_dict:
				var stat_value = stats_dict[stat_name]
				var stat_label = Label.new()

				var stat_text = stat_name.capitalize().replace("_", " ") + ": "
				if stat_value is Array and stat_value.size() == 2 and "damage" in stat_name: 
					stat_text += str(stat_value[0]) + "-" + str(stat_value[1])
				elif stat_value is float:
					stat_text += "%.1f" % stat_value
					if "percent" in stat_name or "speed" in stat_name:
						stat_text += "%"
				else:
					stat_text += str(stat_value)

				stat_label.text = stat_text
				$VBoxContainer/StatsContainer.add_child(stat_label)

	if item_data.has("level_req") and item_data.level_req > 1:
		var req_label = Label.new()
		req_label.text = "Requires Level: " + str(item_data.level_req)
		req_label.modulate = Color.ORANGE
		$VBoxContainer/StatsContainer.add_child(req_label)

	if item_data.has("stat_req"):
		for stat_name in item_data.stat_req:
			var req_value = item_data.stat_req[stat_name]
			if req_value > 0:
				var req_label = Label.new()
				req_label.text = "Requires %s: %d" % [stat_name.capitalize(), req_value]
				req_label.modulate = Color.ORANGE
				$VBoxContainer/StatsContainer.add_child(req_label)

	await get_tree().process_frame
	await get_tree().process_frame

	var vbox = $VBoxContainer
	if is_instance_valid(vbox):
		custom_minimum_size = vbox.size + Vector2(20, 20)
	else:
		printerr("Tooltip Error: VBoxContainer not found!")
		custom_minimum_size = Vector2(100, 50)
