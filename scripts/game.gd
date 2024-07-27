extends Node3D

@export var refine_slot: Slot
@export var refine_cost_label: Label3D
@export var refine_button: ClickableText
@export var refine_progress: ProgressBar3D
@export var distill_slot1: Slot
@export var distill_slot2: Slot
@export var distill_cost_label: Label3D
@export var distill_button: ClickableText
@export var distill_progress: ProgressBar3D
@export var material_slots: Array[Slot]
@export var reagent_slots: Array[Slot]
@export var potion_slots: Array[Slot]
@export var requests: Array[Request]
@export var end_turn_button: ClickableText
@export var energy_label: Label3D
@export var gold_label: Label3D
@export var renown_label: Label3D

var selected_slot: Slot
var energy_cap: int
var energy: int
var gold: int
var renown: int
var turn: int = 1
var refine_cost: int = 1
var distill_cost: int = 1
var request_queue: Array[RequestData]

func create_card(type:Constants.ID):
	var info
	match type:
		Constants.ID.HERB_HEALTH:
			info = CardData.create("Green Herb",Constants.CATEGORY.MATERIAL,
			 Constants.TYPE.HEALTH, 1, 0)
		Constants.ID.HERB_MANA:
			info = CardData.create("Blue Herb",Constants.CATEGORY.MATERIAL,
			 Constants.TYPE.MANA, 1, 0)
		Constants.ID.DUST_HEALTH:
			info = CardData.create("Regenerating\n Dust",Constants.CATEGORY.REAGENT,
			 Constants.TYPE.HEALTH, 1, 0)
		Constants.ID.DUST_MANA:
			info = CardData.create("Enervating\n Dust",Constants.CATEGORY.REAGENT,
			 Constants.TYPE.MANA, 1, 0)
		Constants.ID.POTION_HEALTH:
			info = CardData.create("Health Potion",Constants.CATEGORY.POTION,
			 Constants.TYPE.HEALTH, 1, 0)
		Constants.ID.POTION_MANA:
			info = CardData.create("Mana Potion",Constants.CATEGORY.POTION,
			 Constants.TYPE.MANA, 1, 0)
		Constants.ID.POTION_STAMINA:
			info = CardData.create("Stamina Potion",Constants.CATEGORY.POTION,
			 Constants.TYPE.STAMINA, 1, 0)
	var new_card = Card.create(info)
	add_child(new_card)
	return new_card

func set_energy(amount:int):
	energy = amount
	energy_label.text = "Energy: " + str(energy) + "/" + str(energy_cap)
	if energy <= 0:
		energy_label.set_modulate(Color(1,0,0))
	else:
		energy_label.set_modulate(Color(1,1,1))

func set_gold(amount:int):
	gold = amount
	gold_label.text = "Gold: " + str(gold)

func set_renown(amount:int):
	renown = amount
	renown_label.text = "Renown: " + str(renown)
	if renown < 100:
		renown_label.set_modulate(Color(1,0,0))
	elif renown > 200:
		renown_label.set_modulate(Color(0,0,1))
	elif renown > 150:
		renown_label.set_modulate(Color(0,1,0))
	else:
		renown_label.set_modulate(Color(1,1,1))

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
	distill_button.hide()
	for request in requests:
		request.set_visibility(false)
	end_turn_button.set_text("End Turn")
	end_turn_button.set_hover_colour(Color(0,0,1))
	energy_cap = 3
	set_energy(energy_cap)
	set_gold(0)
	set_renown(100)
	
	material_slots[0].assign_card(create_card(Constants.ID.HERB_HEALTH))
	material_slots[1].assign_card(create_card(Constants.ID.HERB_HEALTH))
	#material_slots[2].assign_card(create_card(Constants.ID.HERB_HEALTH))
	requests[0].assign_request(RequestData.create(
		"Health Potion", Constants.TYPE.HEALTH, 5, 10))
	#requests[1].assign_request(RequestData.create(
		#"Health Potion", Constants.ID.POTION_HEALTH, 3, 10))

func _process(delta):
	if Input.is_action_just_pressed("mouse_right"):
		selected_slot.select_slot(false)
		selected_slot = null
	
	if refine_slot.has_card():
		refine_button.show()
		refine_cost_label.show()
		refine_cost_label.text = "Cost:\n" + str(refine_cost) + " Energy"
	else:
		refine_button.hide()
		refine_cost_label.hide()
	
	if distill_slot1.has_card() && distill_slot2.has_card():
		distill_button.show()
		distill_cost_label.show()
		distill_cost_label.text = "Cost:\n" + str(distill_cost) + " Energy"
	else:
		distill_button.hide()
		distill_cost_label.hide()

func _on_click_slot_signal(slot):
	print("Click Slot received")
	if slot.is_locked:
		print("Slot is locked, do not select/swap cards in this slot")
	elif selected_slot == null && slot.has_card():
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
		if energy >= refine_cost:
			set_energy(energy - refine_cost)
			refine_progress.start_timer(2.0)
			refine_slot.set_lock(true)
	if button == distill_button:
		if energy >= distill_cost:
			set_energy(energy - distill_cost)
			distill_progress.start_timer(2.0)
			distill_slot1.set_lock(true)
			distill_slot2.set_lock(true)
	for request in requests:
		if button == request._reject_button:
			request.set_visibility(false)
	if button == end_turn_button:
		set_energy(energy_cap)
		for request in requests:
			if request._slot.has_card():
				if request._slot.card.data.type == request.data.type:
					set_renown(renown + request.data.renown)
				else:
					set_renown(renown - request.data.renown)
				set_gold(gold + request.data.gold)
				request._slot.card.queue_free()
				request.data = null
				request.set_visibility(false)
		turn += 1
		if turn == 2:
			add_material_card(create_card(Constants.ID.HERB_MANA))
			add_material_card(create_card(Constants.ID.HERB_MANA))
			request_queue.push_back(RequestData.create(
				"Mana Potion", Constants.TYPE.MANA, 5, 10))
			populate_requests()

func add_material_card(card:Card):
	for slot in material_slots:
		if !slot.has_card():
			slot.assign_card(card)
			break

func populate_requests():
	for request in requests:
		if request.data == null:
			var data = request_queue.pop_front()
			if data != null:
				request.assign_request(data)

func _on_progress_bar_complete_signal(bar):
	if bar == refine_progress:
		if refine_slot.has_card():
			refine_slot.set_lock(false)
			refine_material(refine_slot.card.data.type)
			refine_slot.card.queue_free()
	if bar == distill_progress:
		if distill_slot1.has_card() && distill_slot2.has_card():
			distill_slot1.set_lock(false)
			distill_slot2.set_lock(false)
			distill_reagents(distill_slot1.card.data.type, distill_slot2.card.data.type)
			distill_slot1.card.queue_free()
			distill_slot2.card.queue_free()

func refine_material(type:Constants.TYPE):
	var new_card
	match type:
		Constants.TYPE.HEALTH:
			new_card = create_card(Constants.ID.DUST_HEALTH)
		Constants.TYPE.MANA:
			new_card = create_card(Constants.ID.DUST_MANA)
	
	for slot in reagent_slots:
		if !slot.has_card():
			slot.assign_card(new_card)
			break

func distill_reagents(type1:Constants.TYPE, type2:Constants.TYPE):
	var new_card
	match type1:
		Constants.TYPE.HEALTH:
			if type2 == Constants.TYPE.HEALTH:
				new_card = create_card(Constants.ID.POTION_HEALTH)
			if type2 == Constants.TYPE.MANA:
				new_card = create_card(Constants.ID.POTION_STAMINA)
		Constants.TYPE.MANA:
			if type2 == Constants.TYPE.MANA:
				new_card = create_card(Constants.ID.POTION_MANA)
			if type2 == Constants.TYPE.HEALTH:
				new_card = create_card(Constants.ID.POTION_STAMINA)
	
	for slot in potion_slots:
		if !slot.has_card():
			slot.assign_card(new_card)
			break

func _on_return_to_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
