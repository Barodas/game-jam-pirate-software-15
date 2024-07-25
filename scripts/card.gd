extends MeshInstance3D

@onready var _name_label = $NameLabel
@onready var _energy_label = $EnergyLabel
@onready var _gold_label = $GoldLabel
@onready var _border = $Border

var data
var is_hovered = false
var is_selected = false

func _process(delta):
	#var random = randi_range(0, 2)
	#var col
	#match random:
		#0:
			#col = Color(1,1,0)
		#1:
			#col = Color(0,1,0)
		#2:
			#col = Color(0,1,1)
	#
	#change_colour(col)
	# Selection
	if is_hovered && Input.is_action_pressed("mouse_left"):
		is_selected = true
	if is_selected && Input.is_action_pressed("mouse_right"):
		is_selected = false
	
	# Highlighting
	if is_selected: 
		_border.show()
		if is_hovered:
			change_colour(Color(0,1,0))
		else:
			change_colour(Color(0,0,1))
	else:
		if is_hovered:
			_border.show()
			change_colour(Color(1,1,0))
		else:
			_border.hide()

func _physics_process(delta):
	#set_hovered(false)
	pass

func set_hovered(state: bool):
	is_hovered = state

func change_colour(col:Color):
	var mat = _border.get_active_material(0)
	mat.albedo_color = col

static func create(info: CardData):
	var scene = load("res://scenes/card.tscn")
	var instance = scene.instance()
	instance.data = info
	instance._name_label.text = info.name
	instance._energy_label.text = info.energy
	instance._gold_label.text = info.gold
	return instance

func _on_static_body_3d_mouse_entered():
	is_hovered = true
	print("Card Mouse entered")

func _on_static_body_3d_mouse_exited():
	is_hovered = false
	print("Card Mouse exited")
