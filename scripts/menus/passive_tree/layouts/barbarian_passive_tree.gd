extends Node


const TREE_LAYOUT = {
	"start":      { "type": "start",     "pos": Vector2(100, 400), "connections": ["str1", "str2", "str3"] },

	# Branch 1 (Top)
	"str1":       { "type": "strength",  "pos": Vector2(300, 200), "connections": ["str1_dex1", "str1_wis1"] },
	"str1_dex1":  { "type": "dexterity", "pos": Vector2(500, 150), "connections": ["str1_dex1_str1"] },
	"str1_dex1_str1": { "type": "strength", "pos": Vector2(700, 150), "connections": ["str1_dex1_str1_wis1"] },
	"str1_dex1_str1_wis1": { "type": "wisdom", "pos": Vector2(900, 150), "connections": [] },
	"str1_wis1":  { "type": "wisdom",    "pos": Vector2(500, 250), "connections": ["str1_wis1_dex1"] },
	"str1_wis1_dex1": { "type": "dexterity", "pos": Vector2(700, 250), "connections": [] },

	# Branch 2 (Middle)
	"str2":       { "type": "strength",  "pos": Vector2(300, 400), "connections": ["str2_wis1", "str2_wis2"] },
	"str2_wis1":  { "type": "wisdom",    "pos": Vector2(500, 350), "connections": ["str2_wis1_str1"] },
	"str2_wis1_str1": { "type": "strength", "pos": Vector2(700, 350), "connections": [] },
	"str2_wis2":  { "type": "wisdom",    "pos": Vector2(500, 450), "connections": ["str2_wis2_dex1"] },
	"str2_wis2_dex1": { "type": "dexterity", "pos": Vector2(700, 450), "connections": ["str2_wis2_dex1_str1"] },
	"str2_wis2_dex1_str1": { "type": "strength", "pos": Vector2(900, 450), "connections": [] },

	# Branch 3 (Bottom)
	"str3":       { "type": "strength",  "pos": Vector2(300, 600), "connections": ["str3_dex1", "str3_str1"] },
	"str3_dex1":  { "type": "dexterity", "pos": Vector2(500, 550), "connections": ["str3_dex1_wis1"] },
	"str3_dex1_wis1": { "type": "wisdom", "pos": Vector2(700, 550), "connections": ["str3_dex1_wis1_dex1"] },
	"str3_dex1_wis1_dex1": { "type": "dexterity", "pos": Vector2(900, 550), "connections": [] },
	"str3_str1":  { "type": "strength",  "pos": Vector2(500, 650), "connections": ["str3_str1_wis1"] },
	"str3_str1_wis1": { "type": "wisdom", "pos": Vector2(700, 650), "connections": ["str3_str1_wis1_str1"] },
	"str3_str1_wis1_str1": { "type": "strength", "pos": Vector2(900, 650), "connections": [] },

	# Example of adding more nodes later:
	# "another_node": { "type": "dexterity", "pos": Vector2(1100, 150), "connections": [] },
	# And update "str1_dex1_str1_wis1"'s connections:
	# "str1_dex1_str1_wis1": { "type": "wisdom", "pos": Vector2(900, 150), "connections": ["another_node"] },
}
