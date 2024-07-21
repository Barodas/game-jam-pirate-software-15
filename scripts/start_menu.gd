extends Control

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
