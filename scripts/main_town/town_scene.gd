extends Node2D

func _ready():
	# Check if we're returning from a building
	if Global.current_building_name != "":
		position_player_outside_building(Global.current_building_name)

func position_player_outside_building(building_name):
	var building_path = "Buildings/" + building_name + "/" + building_name
	if has_node(building_path):
		var building = get_node(building_path)
		if building.has_node("Door"):
			var door = building.get_node("Door")
			var player = $Player
			
			# Position player slightly below the door
			var spawn_position = door.global_position + Vector2(0, 60)
			player.position = spawn_position
			print("Positioned player outside of " + building_name)
			
			# Clear the current building
			Global.current_building_name = ""
	else:
		print("Building not found: " + building_name)
		Global.current_building_name = ""
