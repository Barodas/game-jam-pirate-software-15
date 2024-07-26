class_name Card extends MeshInstance3D

@onready var _name_label = $NameLabel
@onready var _energy_label = $EnergyLabel
@onready var _gold_label = $GoldLabel
@onready var _border_highlight = $BorderHighlight
@onready var _border_selected = $BorderSelected

var data
var is_hovered = false
var is_selected = false

static func create(info: CardData):
	var instance = preload("res://scenes/card.tscn").instantiate()
	instance.data = info
	print("Created a Card")
	return instance

func _ready():
	if data:
		_name_label.text = data.name
		_energy_label.text = "Energy: " + str(data.energy)
		_gold_label.text = "Gold: " + str(data.gold)
		print("Initialised a ", data.name, " Card")

func _process(delta):
	# Highlighting	
	if is_hovered:
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

func set_state(hovered: bool, selected: bool):
	is_hovered = hovered
	is_selected = selected

func change_hovered_colour(col:Color):
	var mat = _border_highlight.get_active_material(0)
	mat.albedo_color = col
