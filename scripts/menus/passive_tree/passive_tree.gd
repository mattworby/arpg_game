extends Control

signal passive_tree_changed(data)

func _ready():	
	print('ready')

func toggle_passive_tree():
	visible = !visible
