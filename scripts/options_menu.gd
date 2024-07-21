extends Control

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_file("res://scenes/start_menu.tscn")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
