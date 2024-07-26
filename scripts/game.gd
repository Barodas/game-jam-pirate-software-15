extends Node3D

enum CARD_TYPE {HERB_HEALTH, DUST_HEALTH, POTION_HEALTH}

var selected_card: Card
var selected_slot: Slot
@export var refine_slot: Slot
@export var distill_slot1: Slot
@export var distill_slot2: Slot
@export var material_slots: Array[Slot]
@export var reagent_slots: Array[Slot]
@export var potion_slots: Array[Slot]

func create_card(type:CARD_TYPE):
	var info
	match type:
		CARD_TYPE.HERB_HEALTH:
			info = CardData.create("Green Herb", 1, 0)
	var new_card = Card.create(info)
	add_child(new_card)
	return new_card

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_file("res://scenes/start_menu.tscn")

func _ready():
	randomize()
	Signals.click_slot.connect(_on_click_slot_signal)
	
	# Populate Hand
	material_slots[0].assign_card(create_card(CARD_TYPE.HERB_HEALTH))
	material_slots[1].assign_card(create_card(CARD_TYPE.HERB_HEALTH))
	material_slots[2].assign_card(create_card(CARD_TYPE.HERB_HEALTH))

func _process(delta):
	if Input.is_action_just_pressed("mouse_right"):
		selected_slot.select_slot(false)
		selected_slot = null

func _on_click_slot_signal(slot):
	print("Click Slot received")
	if selected_slot == null && slot.has_card():
		print("Selecting slot: ", slot.name)
		selected_slot = slot
		slot.select_slot(true)
	elif selected_slot != null && selected_slot != slot:
		if slot.has_card():
			print("Swapping selected slot: ", selected_slot.name, " with slot: ", slot.name)
			var card_to_swap = slot.card
			slot.assign_card(selected_slot.card)
			selected_slot.assign_card(card_to_swap)
			selected_slot.select_slot(false)
			selected_slot = null
		else:
			print("Moving card in selected slot: ", selected_slot.name, " to slot: ", slot.name)
			slot.assign_card(selected_slot.card)
			selected_slot.assign_card(null)
			selected_slot.select_slot(false)
			selected_slot = null

func _on_return_to_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
