extends Node3D

@onready var _ui = $UI
@onready var _game_over_screen = $UI/GameOver
@onready var _game_over_description_label = $UI/GameOver/MarginContainer/VBoxContainer/DescriptionLabel

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

@export var summary_page: MarginContainer
@export var summary_turn_label: Label
@export var summary_request_label: Label
@export var summary_renown_label: Label
@export var summary_sales_label: Label
@export var summary_expense_label: Label
@export var summary_tax_label: Label
@export var summary_total_label: Label

@export var event_page: MarginContainer
@export var event_title_label: Label
@export var event_contents_label: Label
@export var event_options1_button: Button
@export var event_options2_button: Button
@export var event_options3_button: Button

var selected_slot: Slot
var turn: int = 1
var energy_cap: int
var energy: int
var renown: int
var renown_gain: int
var request_count: int
var request_gain: int
var gold: int
var sales: int
var expenses: int
var tax: int
var refine_cost: int = 1
var distill_cost: int = 1
var process_time: float = 1.5
var request_queue: Array[RequestData]

func set_energy(amount:int):
	energy = amount
	energy_label.text = "Energy: " + str(energy) + "/" + str(energy_cap)
	if energy <= 0:
		energy_label.set_modulate(Color(1,0,0))
	else:
		energy_label.set_modulate(Color(1,1,1))

func set_gold(amount:int):
	if amount > gold:
		sales = amount - gold
	else:
		expenses = gold - amount
	gold = amount
	gold_label.text = "Gold: " + str(gold)

func set_renown(amount:int):
	renown_gain = amount - renown
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
	_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_game_over_screen.hide()
	summary_page.hide()
	event_page.hide()
	refine_button.hide()
	distill_button.hide()
	for request in requests:
		request.set_visibility(false)
	end_turn_button.set_text("End Turn")
	end_turn_button.set_hover_colour(Color(0,0,1))
	energy_cap = 3
	set_energy(energy_cap)
	gold = 4
	set_gold(gold)
	tax = 2
	renown = 100
	set_renown(renown)
	
	generate_turn_cards()
	generate_turn_requests()

func generate_turn_cards():
	var cards = ContentFactory.generate_cards(turn)
	for card in cards:
		add_to_slot(material_slots, card)

func generate_turn_requests():
	var new_requests = ContentFactory.generate_requests(turn)
	for request in new_requests:
		request_queue.push_back(request)
	populate_requests()

func _process(delta):
	if Input.is_action_just_pressed("mouse_right") && selected_slot != null:
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
			refine_progress.start_timer(process_time)
			refine_slot.set_lock(true)
	if button == distill_button:
		if energy >= distill_cost:
			set_energy(energy - distill_cost)
			distill_progress.start_timer(process_time)
			distill_slot1.set_lock(true)
			distill_slot2.set_lock(true)
	for request in requests:
		if button == request._reject_button:
			request.data = null
			request.set_visibility(false)
			populate_requests()
	if button == end_turn_button:
		# Prepare end of turn stats
		end_turn_button.hide()
		for request in requests:
			if request._slot.has_card():
				if request._slot.card.data.type == request.data.type:
					set_renown(renown + request.data.renown)
				else:
					set_renown(renown - request.data.renown)
				set_gold(gold + request.data.gold)
				request_count += 1
				request_gain += 1
				request._slot.card.queue_free()
				request.data = null
				request.set_visibility(false)
		set_gold(gold - tax)
		if gold <= 0:
			game_over("Out of Gold, The kingdom has taken your shop")
		
		# Populate summary page
		summary_turn_label.text = "Turn: " + str(turn)
		summary_request_label.text = "Requests fulfilled: " + str(request_count) + " (+" + str(request_gain) + ")"
		if renown_gain >= 0:
			summary_renown_label.text = "Renown: " + str(renown) + " (+" + str(renown_gain) + ")"
		else:
			summary_renown_label.text = "Renown: " + str(renown) + " (-" + str(renown_gain) + ")"
		summary_sales_label.text = "Sales: " + str(sales)
		summary_expense_label.text = "Expenses: " + str(expenses)
		summary_tax_label.text = "Tax: " + str(tax)
		summary_total_label.text = "Total: " + str(gold)
		summary_page.show()

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
			new_card = Card.create(ContentFactory.create_card_data(Constants.ID.DUST_HEALTH))
		Constants.TYPE.MANA:
			new_card = Card.create(ContentFactory.create_card_data(Constants.ID.DUST_MANA))
	add_to_slot(reagent_slots, new_card)

func distill_reagents(type1:Constants.TYPE, type2:Constants.TYPE):
	var new_card
	match type1:
		Constants.TYPE.HEALTH:
			if type2 == Constants.TYPE.HEALTH:
				new_card = Card.create(ContentFactory.create_card_data(Constants.ID.POTION_HEALTH))
			if type2 == Constants.TYPE.MANA:
				new_card = Card.create(ContentFactory.create_card_data(Constants.ID.POTION_STAMINA))
		Constants.TYPE.MANA:
			if type2 == Constants.TYPE.MANA:
				new_card = Card.create(ContentFactory.create_card_data(Constants.ID.POTION_MANA))
			if type2 == Constants.TYPE.HEALTH:
				new_card = Card.create(ContentFactory.create_card_data(Constants.ID.POTION_STAMINA))
	add_to_slot(potion_slots, new_card)

func add_to_slot(slots:Array[Slot], card: Card):
	for slot in slots:
		if !slot.has_card():
			add_child(card)
			slot.assign_card(card)
			break

func game_over(description: String):
	_ui.mouse_filter = Control.MOUSE_FILTER_STOP
	_game_over_description_label.text = description
	_game_over_screen.show()

func _on_return_to_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")

func _on_next_turn_button_pressed():
	summary_page.hide()
	# Prepare next turn
	turn += 1
	renown_gain = 0
	request_gain = 0
	sales = 0
	expenses = 0
	set_energy(energy_cap)
	generate_turn_cards()
	generate_turn_requests()
	#if turn == 2:
		#request_queue.push_back(RequestData.create(
			#"Mana Potion", Constants.TYPE.MANA, 5, 10))
		#populate_requests()
	end_turn_button.show()
