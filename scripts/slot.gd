class_name Slot extends Node3D

@export var category: Constants.CATEGORY = Constants.CATEGORY.MATERIAL
var card: Card
var is_hovered: bool = false
var is_selected: bool = false
var is_locked: bool = false

func _process(delta):
	# Selection
	if is_hovered && Input.is_action_just_pressed("mouse_left"):
		Signals.click_slot.emit(self)

func has_card():
	return card != null

func set_lock(state):
	is_locked = state
	update_card()

func update_card():
	if has_card():
		card.set_state(is_hovered, is_selected, is_locked)

func assign_card(assigned_card: Card):
	card = assigned_card
	if has_card():
		card.global_position = self.global_position
		update_card()

func select_slot(state: bool):
	is_selected = state
	update_card()

func _on_area_3d_mouse_entered():
	is_hovered = true
	update_card()

func _on_area_3d_mouse_exited():
	is_hovered = false
	update_card()
