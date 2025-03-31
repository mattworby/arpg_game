extends Node


const passive = {
	"start": {
		"name": "start node",
		"description": "start of passive tree",
		"attribute": "none",
		"value": 0,
		"image": "res://assets/passives/start.png"
	},
	"strength": {
		"name": "add strength",
		"description": "adds 10 strength",
		"attribute": "strength",
		"value": 10,
		"image": "res://assets/passives/strength.png"
	},
	"wisdom": {
		"name": "add wisdom",
		"description": "adds 10 wisdom",
		"attribute": "wisdom",
		"value": 10,
		"image": "res://assets/passives/wisdom.png"
	},
	"dexterity": {
		"name": "add dexterity",
		"description": "adds 10 dexterity",
		"attribute": "dexterity",
		"value": 10,
		"image": "res://assets/passives/dexterity.png"
	}
}

static func get_passive(passive_id):
	if passive.has(passive_id):
		return passive[passive_id]
	return null
