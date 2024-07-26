class_name ClickableText extends Node3D

@onready var _label = $Label
var is_hovered: bool = false

func _process(delta):
	if is_hovered && Input.is_action_just_pressed("mouse_left"):
		Signals.click_button.emit(self)
	
	if is_hovered:
		_label.set_modulate(Color(0,1,0))
	else:
		_label.set_modulate(Color(1,1,1))

func _on_area_3d_mouse_entered():
	is_hovered = true

func _on_area_3d_mouse_exited():
	is_hovered = false
