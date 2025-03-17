extends StaticBody2D

@export var building_width: float = 150
@export var building_height: float = 120
@export var house_building_name: String = 'HouseBuilding'
@export var building_color: Color = Color(0.5, 0.3, 0.2)
@export var door_position: Vector2 = Vector2(75, 120)  # Position relative to building
@export var interior_scene_path: String = "res://scenes/interiors/house_interior.tscn"

var building_rect: ColorRect
var door: HouseDoor

func _ready():
	# Create the building visual
	building_rect = ColorRect.new()
	building_rect.size = Vector2(building_width, building_height)
	building_rect.color = building_color
	add_child(building_rect)
	
	if has_node("CollisionShape2D"):
		var collision_shape = $CollisionShape2D
		var shape = RectangleShape2D.new()
		shape.size = Vector2(building_width, building_height)
		collision_shape.shape = shape
		collision_shape.position = Vector2(building_width/2, building_height/2)
	
	# Add a door to the building
	add_door()

func add_door():
	# Instance the door scene
	door = HouseDoor.new()
	door.house_building_name = house_building_name
	door.interior_scene_path = interior_scene_path
	
	# Position door at the bottom center of the building
	door.position = door_position
	
	add_child(door)
