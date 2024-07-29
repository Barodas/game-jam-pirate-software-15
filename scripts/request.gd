class_name Request extends Node3D

@onready var _background = $Background
@onready var _duration_label = $Background/DurationLabel
@onready var _request_label = $Background/RequestLabel
@onready var _gold_label = $Background/GoldLabel
@onready var _renown_label = $Background/RenownLabel
@onready var _slot = $Background/TurnInSlot
@onready var _reject_button = $Background/ClickableText

var data: RequestData

func _ready():
	_reject_button.set_text("Reject")
	_reject_button.set_hover_colour(Color(1,0,0))

func _process(delta):
	if _slot.has_card():
		_reject_button.hide()
	else:
		_reject_button.show()

func set_visibility(state:bool):
	if state:
		_background.show()
	else:
		_background.hide()

func update_duration():
	_duration_label.text = str(data.duration)

func assign_request(assigned_request: RequestData):
	data = assigned_request
	_request_label.text = data.name
	_gold_label.text = "Gold: " + str(data.gold)
	_renown_label.text = "Renown: " + str(data.renown)
	update_duration()
	set_visibility(true)
