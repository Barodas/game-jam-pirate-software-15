extends Node3D

@export var mat_green: Material
@export var mat_blue: Material
@export var mat_yellow: Material

@onready var _bottle = $Bottle01/Bottle1

func set_colour(colour:Constants.BOTTLE_COLOUR):
	match colour:
		Constants.BOTTLE_COLOUR.GREEN:
			_bottle.material_override = mat_green
		Constants.BOTTLE_COLOUR.BLUE:
			_bottle.material_override = mat_blue
		Constants.BOTTLE_COLOUR.YELLOW:
			_bottle.material_override = mat_yellow
