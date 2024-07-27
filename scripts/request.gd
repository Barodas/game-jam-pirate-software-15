class_name Request extends Node3D

@onready var _background = $Background
@onready var _request_label = $Background/RequestLabel
@onready var _reward_label = $Background/RewardLabel
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

func assign_request(assigned_request: RequestData):
	data = assigned_request
	_request_label.text = data.name
	_reward_label.text = "Reward: " + str(data.gold) + " Gold"
	set_visibility(true)
