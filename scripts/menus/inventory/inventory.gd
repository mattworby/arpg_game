extends Control

signal inventory_changed(data)

func _ready():	
	visible = !visible
	
	return true

func toggle_inventory():
	visible = !visible
