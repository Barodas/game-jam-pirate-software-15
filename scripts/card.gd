class_name Card extends MeshInstance3D

@onready var _name_label = $NameLabel
@onready var _energy_label = $EnergyLabel
@onready var _gold_label = $GoldLabel
@onready var _border_highlight = $BorderHighlight
@onready var _border_selected = $BorderSelected

var data
var is_hovered = false
var is_selected = false

func _ready():
	Signals.select_card.connect(_on_select_card_signal)

func _process(delta):
	# Selection
	if is_hovered && Input.is_action_just_pressed("mouse_left"):
		Signals.click_card.emit(self)
	
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

func _physics_process(delta):
	#set_hovered(false)
	pass

func set_hovered(state: bool):
	is_hovered = state

func change_hovered_colour(col:Color):
	var mat = _border_highlight.get_active_material(0)
	mat.albedo_color = col

static func create(info: CardData):
	var scene = load("res://scenes/card.tscn")
	var instance = scene.instance()
	instance.data = info
	instance._name_label.text = info.name
	instance._energy_label.text = info.energy
	instance._gold_label.text = info.gold
	return instance

func _on_select_card_signal(card:Card):
	if card == self:
		is_selected = true
	else:
		is_selected = false

func _on_static_body_3d_mouse_entered():
	is_hovered = true
	#print("Card Mouse entered")

func _on_static_body_3d_mouse_exited():
	is_hovered = false
	#print("Card Mouse exited")
