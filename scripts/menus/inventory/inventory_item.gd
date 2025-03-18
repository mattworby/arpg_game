# InventoryItem.gd - Attach to the InventoryItem scene
extends TextureRect

var item_id = ""
var item_name = ""
var item_type = ""
var quantity = 1
var stats = {}

func _ready():
	# Set default size
	custom_minimum_size = Vector2(32, 32)
	expand_mode = 1
	stretch_mode = 3
	
	# Create tooltip
	tooltip_text = item_name

func initialize(id, l_name, type, icon_path, item_quantity=1, item_stats={}):
	item_id = id
	item_name = l_name
	item_type = type
	quantity = item_quantity
	stats = item_stats
	
	# Load texture
	# texture = load(icon_path)
	
	# Update tooltip
	update_tooltip()
	
	# If stackable item, show quantity
	if quantity > 1:
		$QuantityLabel.text = str(quantity)
		$QuantityLabel.visible = true
	else:
		$QuantityLabel.visible = false

func update_tooltip():
	# Create detailed tooltip based on item type and stats
	var l_tooltip_text = item_name
	
	if item_type in ["weapon", "armor", "helmet", "gloves", "boots"]:
		l_tooltip_text += "\n" + item_type.capitalize()
		
		# Add stats if available
		for stat in stats:
			l_tooltip_text += "\n" + stat + ": " + str(stats[stat])
	
	elif item_type == "consumable":
		l_tooltip_text += "\nConsumable"
		# Add effect description
		if stats.has("effect"):
			l_tooltip_text += "\n" + stats["effect"]
	
	self.tooltip_text = l_tooltip_text

func get_equip_type():
	# Return suitable equipment slot type
	match item_type:
		"weapon": return "weapon"
		"helmet": return "head"
		"armor": return "body"
		"gloves": return "hands"
		"boots": return "feet"
		"ring": return "ring"
		"amulet": return "amulet"
		_: return ""  # Not equippable
