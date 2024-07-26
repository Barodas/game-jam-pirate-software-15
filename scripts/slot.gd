class_name Slot extends Node3D

var card: Card
var is_hovered: bool = false

func _process(delta):
	# Selection
	if is_hovered && Input.is_action_just_pressed("mouse_left"):
		Signals.click_slot.emit(self)

func assign_card(assigned_card: Card):
	card = assigned_card
	card.global_position = self.global_position

func _on_area_3d_mouse_entered():
	is_hovered = true
	#print("Slot Mouse entered")

func _on_area_3d_mouse_exited():
	is_hovered = false
	#print("Slot Mouse exited")
