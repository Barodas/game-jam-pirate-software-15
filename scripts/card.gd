class_name Card extends MeshInstance3D

@export var mat_green: Material
@export var mat_blue: Material
@export var mat_yellow: Material

@onready var _name_label = $NameLabel
@onready var _energy_label = $EnergyLabel
@onready var _gold_label = $GoldLabel
@onready var _border_highlight = $BorderHighlight
@onready var _border_selected = $BorderSelected
@onready var _border_locked = $BorderLocked
@onready var _bottle = $Bottle
@onready var _dust = $Dust/Dust
@onready var _leaf = $Leaf/Leaf

var data
var is_hovered = false
var is_selected = false
var is_locked = false

static func create(info: CardData):
	var instance = preload("res://scenes/card.tscn").instantiate()
	instance.data = info
	print("Created a Card")
	return instance

func _ready():
	_bottle.hide()
	_dust.hide()
	_leaf.hide()
	if data:
		_name_label.text = data.name
		_energy_label.text = "Energy: " + str(data.energy)
		_gold_label.text = "Gold: " + str(data.gold)
		match data.name:
			"Green Herb":
				_leaf.show()
				_leaf.material_override = mat_green
			"Blue Herb":
				_leaf.show()
				_leaf.material_override = mat_blue
			"Regenerating\n Dust":
				_dust.show()
				_dust.material_override = mat_green
			"Enervating\n Dust":
				_dust.show()
				_dust.material_override = mat_blue
			"Health Potion":
				_bottle.show()
				_bottle.set_colour(Constants.BOTTLE_COLOUR.GREEN)
			"Mana Potion":
				_bottle.show()
				_bottle.set_colour(Constants.BOTTLE_COLOUR.BLUE)
			"Stamina Potion":
				_bottle.show()
				_bottle.set_colour(Constants.BOTTLE_COLOUR.YELLOW)
		print("Initialised a ", data.name, " Card")

func _process(delta):
	# Highlighting
	_border_locked.hide()
	if is_locked:
		_border_locked.show()
		_border_highlight.hide()
		_border_selected.hide()
	elif is_hovered:
		_border_highlight.show()
		_border_selected.hide()
		if is_selected:
			change_hovered_colour(Color(0,1,0))
		else:
			change_hovered_colour(Color(1,1,0))
	else:
		if is_selected:
			_border_selected.show()
		else:
			_border_selected.hide()
			_border_highlight.hide()

func set_state(hovered: bool, selected: bool, locked: bool):
	is_hovered = hovered
	is_selected = selected
	is_locked = locked

func change_hovered_colour(col:Color):
	var mat = _border_highlight.get_active_material(0)
	mat.albedo_color = col
