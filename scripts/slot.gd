class_name Slot extends Node3D

var has_card: bool
var is_hovered: bool = false

func _process(delta):
	# Selection
	if is_hovered && Input.is_action_just_pressed("mouse_left"):
		Signals.click_slot.emit(self)

func _on_area_3d_mouse_entered():
	is_hovered = true
	#print("Slot Mouse entered")

func _on_area_3d_mouse_exited():
	is_hovered = false
	#print("Slot Mouse exited")
