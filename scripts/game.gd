extends Node3D

enum CARD_TYPE {HERB_HEALTH, DUST_HEALTH, POTION_HEALTH}

func create_card(type:CARD_TYPE):
	var scene = load("res://scenes/card.tscn")
	var instance = scene.instance()
	instance.name
	var info
	match type:
		CARD_TYPE.HERB_HEALTH:
			info = CardData.create("Green Herb", 1, 0)

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_file("res://scenes/start_menu.tscn")

func _ready():
	randomize()

func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	var cam = $World/Camera3D
	var mousepos = get_viewport().get_mouse_position()
	
	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	print("Hit: ", result.collider.get_parent().name)
	#if result.collider.get_parent().has_method("set_hovered"):
	#	result.collider.get_parent().set_hovered(true)

func _on_return_to_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
