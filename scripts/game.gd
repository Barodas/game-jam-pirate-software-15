extends Node3D

var selected_card: Card
var selected_slot: Slot
@export var refine_slot: Slot
@export var refine_button: ClickableText
@export var refine_progress: ProgressBar3D
@export var distill_slot1: Slot
@export var distill_slot2: Slot
@export var material_slots: Array[Slot]
@export var reagent_slots: Array[Slot]
@export var potion_slots: Array[Slot]

func create_card(type:Constants.ID):
	var info
	match type:
		Constants.ID.HERB_HEALTH:
			info = CardData.create("Green Herb",Constants.CATEGORY.MATERIAL,
			 Constants.TYPE.HEALTH, 1, 0)
		Constants.ID.DUST_HEALTH:
			info = CardData.create("Regen Dust",Constants.CATEGORY.REAGENT,
			 Constants.TYPE.HEALTH, 1, 0)
		Constants.ID.POTION_HEALTH:
			info = CardData.create("Health Potion",Constants.CATEGORY.POTION,
			 Constants.TYPE.HEALTH, 1, 0)
	var new_card = Card.create(info)
	add_child(new_card)
	return new_card

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_file("res://scenes/start_menu.tscn")

func _ready():
	randomize()
	Signals.click_slot.connect(_on_click_slot_signal)
	Signals.click_button.connect(_on_click_button_signal)
	Signals.progress_bar_complete.connect(_on_progress_bar_complete_signal)
	
	# Initialise Board State
	refine_button.hide()
	
	# Populate Hand
	material_slots[0].assign_card(create_card(Constants.ID.HERB_HEALTH))
	material_slots[1].assign_card(create_card(Constants.ID.HERB_HEALTH))
	material_slots[2].assign_card(create_card(Constants.ID.HERB_HEALTH))

func _process(delta):
	if Input.is_action_just_pressed("mouse_right"):
		selected_slot.select_slot(false)
		selected_slot = null
	
	if refine_slot.has_card():
		refine_button.show()
	else:
		refine_button.hide()

func _on_click_slot_signal(slot):
	print("Click Slot received")
	if selected_slot == null && slot.has_card():
		print("Selecting slot: ", slot.name)
		selected_slot = slot
		slot.select_slot(true)
	elif selected_slot != null && selected_slot != slot:
		if slot.category != selected_slot.category:
			print("Category mismatch between selection and target slots")
		elif slot.has_card():
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

func _on_click_button_signal(button):
	if button == refine_button:
		if !refine_slot.has_card():
			print("Refine button pressed without a card in refine slot")
		refine_progress.start_timer(3.0)
		# TODO: Lock refine slot to prevent removing card

func _on_progress_bar_complete_signal(bar):
	if bar == refine_progress:
		if refine_slot.has_card():
			# TODO: Unlock refine slot
			refine_material(refine_slot.card.data.type)
			refine_slot.card.queue_free()
			#refine_slot.assign_card(null)

func refine_material(type:Constants.TYPE):
	var new_card
	match type:
		Constants.TYPE.HEALTH:
			new_card = create_card(Constants.ID.DUST_HEALTH)
	for slot in reagent_slots:
		if !slot.has_card():
			slot.assign_card(new_card)
			break

func _on_return_to_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
