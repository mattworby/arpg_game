extends Control

signal inventory_changed(data)

func _ready():	
	print('ready')

func toggle_inventory():
	visible = !visible
