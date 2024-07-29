extends Node3D

@onready var _ui = $UI
@onready var _game_over_screen = $UI/GameOver
@onready var _game_over_description_label = $UI/GameOver/MarginContainer/VBoxContainer/DescriptionLabel

@export var refine_slot: Slot
@export var refine_cost_label: Label3D
@export var refine_level_label: Label3D
@export var refine_button: ClickableText
@export var refine_progress: ProgressBar3D
@export var distill_slot1: Slot
@export var distill_slot2: Slot
@export var distill_cost_label: Label3D
@export var distill_level_label: Label3D
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
@export var tax_label: Label3D

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
var turn: int = 0
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
var refine_level: int = 1
var refine_cost: int = 1
var refine_upgrade_multiplier = 1
var free_refine_cap = 0
var free_refine_count
var distill_level:int = 1
var distill_cost: int = 1
var distill_upgrade_multiplier = 1
var free_distill_cap = 0
var free_distill_count
var process_time: float = 1.5
var request_queue: Array[RequestData]
var current_event: TurnEvent
var draw_amount = 3
var next_draw_cards: Array[CardData]

func set_energy(amount:int):
	energy = amount
	energy_label.text = "Energy: " + str(energy) + "/" + str(energy_cap)
	if energy <= 0:
		energy_label.set_modulate(Color(1,0,0))
	else:
		energy_label.set_modulate(Color(1,1,1))

func set_gold(amount:int):
	if amount > gold:
		sales = sales + (amount - gold)
	else:
		expenses = expenses - (gold - amount)
	gold = amount
	gold_label.text = "Gold: " + str(gold)
	if gold <= 0:
		gold_label.set_modulate(Color(1,0,0))

func set_tax(amount:int):
	tax = amount
	tax_label.text = "Tax: " + str(tax)
	tax_label.show() if tax > 0 else tax_label.hide()

func set_renown(amount:int):
	renown_gain = renown_gain + (amount - renown)
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
	tax = 0
	renown = 100
	set_renown(renown)
	
	assign_turn_event(ContentFactory.generate_turn_event(turn))

func next_turn():
	# Prepare next turn
	turn += 1
	renown_gain = 0
	request_gain = 0
	sales = 0
	expenses = 0
	free_refine_count = free_refine_cap
	free_distill_count = free_distill_cap
	set_energy(energy_cap)
	generate_turn_cards()
	generate_turn_requests()
	next_draw_cards.clear()
	end_turn_button.show()
	_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE

func generate_turn_cards():
	var cards = ContentFactory.generate_cards(turn, draw_amount, next_draw_cards)
	for card in cards:
		add_to_slot(material_slots, card)

func generate_turn_requests():
	# Update durations, clear out expired requests
	for request in requests:
		if request.data == null:
			continue
		request.data.duration -= 1
		request.update_duration()
		if request.data.duration <= 0:
			request.data = null
			request.set_visibility(false)
	for request in request_queue:
		request.duration -= 1
		if request.duration <= 0:
			request_queue.erase(request)
	
	# Generate new requests for the turn
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
		if refine_slot.card.data.type == Constants.TYPE.UPGRADE_REFINE:
			refine_cost_label.text = "Cost:\n" + str(get_refine_cost()) + " Energy\n" + str(refine_slot.card.data.gold * refine_upgrade_multiplier) + " Gold"
		else:
			refine_cost_label.text = "Cost:\n" + str(get_refine_cost()) + " Energy"
	else:
		refine_button.hide()
		refine_cost_label.hide()
	
	if distill_slot1.has_card() && distill_slot2.has_card() && distill_slot1.card.data.category != Constants.CATEGORY.UPGRADE && distill_slot2.card.data.category != Constants.CATEGORY.UPGRADE:
		distill_button.show()
		distill_cost_label.show()
		distill_cost_label.text = "Cost:\n" + str(get_distill_cost()) + " Energy"
	elif distill_slot1.has_card() && distill_slot1.card.data.category == Constants.CATEGORY.UPGRADE:
		distill_button.show()
		distill_cost_label.show()
		distill_cost_label.text = "Cost:\n" + str(get_distill_cost()) + " Energy\n" + str(distill_slot1.card.data.gold * distill_upgrade_multiplier) + " Gold"
	elif distill_slot2.has_card() && distill_slot2.card.data.category == Constants.CATEGORY.UPGRADE:
		distill_button.show()
		distill_cost_label.show()
		distill_cost_label.text = "Cost:\n" + str(get_distill_cost()) + " Energy\n" + str(distill_slot2.card.data.gold * distill_upgrade_multiplier) + " Gold"
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
		if !valid_slot_category(selected_slot.card, slot):
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

func valid_slot_category(card, target_slot):
	# Regular cards just match on category
	if card.data.category != Constants.CATEGORY.UPGRADE:
		return card.data.category == target_slot.category
	# Upgrade cards must check if they are allowed
	match target_slot.upgrade:
		Constants.ALLOW_UPGRADE.NONE:
			return false
		Constants.ALLOW_UPGRADE.REFINE:
			return card.data.type == Constants.TYPE.UPGRADE_REFINE
		Constants.ALLOW_UPGRADE.DISTILL:
			return card.data.type == Constants.TYPE.UPGRADE_DISTILL
		Constants.ALLOW_UPGRADE.ANY:
			return true

func get_refine_cost(consume_cost = false):
	var cost
	if free_refine_count > 0:
		cost = 0
	else:
		cost = refine_cost
	if consume_cost:
		free_refine_count -= 1
	return cost

func get_distill_cost(consume_cost = false):
	var cost
	if free_distill_count > 0:
		cost = 0
	else:
		cost = distill_cost
	if consume_cost:
		free_distill_count -= 1
	return cost

func _on_click_button_signal(button):
	if button == refine_button:
		if energy >= refine_cost:
			if refine_slot.card.data.category == Constants.CATEGORY.UPGRADE:
				var cost = refine_slot.card.data.gold * refine_upgrade_multiplier
				if gold >= cost:
					set_energy(energy - get_refine_cost(true))
					set_gold(gold - cost)
					refine_progress.start_timer(process_time)
					end_turn_button.hide()
					refine_slot.set_lock(true)
			else:
				set_energy(energy - get_refine_cost(true))
				refine_progress.start_timer(process_time)
				end_turn_button.hide()
				refine_slot.set_lock(true)
	if button == distill_button:
		if energy >= distill_cost:
			if distill_slot1.card.data.category == Constants.CATEGORY.UPGRADE:
				var cost = distill_slot1.card.data.gold * distill_upgrade_multiplier
				if gold >= cost:
					set_energy(energy - get_distill_cost(true))
					set_gold(gold - cost)
					distill_progress.start_timer(process_time)
					end_turn_button.hide()
					distill_slot1.set_lock(true)
			elif distill_slot2.card.data.category == Constants.CATEGORY.UPGRADE:
				var cost = distill_slot2.card.data.gold * distill_upgrade_multiplier
				if gold >= cost:
					set_energy(energy - get_distill_cost(true))
					set_gold(gold - cost)
					distill_progress.start_timer(process_time)
					end_turn_button.hide()
					distill_slot2.set_lock(true)
			else:
				set_energy(energy - get_distill_cost(true))
				distill_progress.start_timer(process_time)
				end_turn_button.hide()
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
			return
		
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
		_ui.mouse_filter = Control.MOUSE_FILTER_STOP
		summary_page.show()

func populate_requests():
	for request in requests:
		if request.data == null:
			var data = request_queue.pop_front()
			if data != null:
				request.assign_request(data)

func _on_progress_bar_complete_signal(bar):
	end_turn_button.show()
	if bar == refine_progress:
		if refine_slot.has_card():
			refine_slot.set_lock(false)
			if refine_slot.card.data.category == Constants.CATEGORY.UPGRADE:
				refine_upgrade_multiplier += 1
				refine_level += 1
				apply_refine_upgrade()
				refine_slot.card.queue_free()
			else:
				refine_material(refine_slot.card.data.type)
				refine_slot.card.queue_free()
	if bar == distill_progress:
		distill_slot1.set_lock(false)
		distill_slot2.set_lock(false)
		if distill_slot1.has_card() && distill_slot2.has_card() && distill_slot1.card.data.category != Constants.CATEGORY.UPGRADE && distill_slot2.card.data.category != Constants.CATEGORY.UPGRADE:
			distill_reagents(distill_slot1.card.data.type, distill_slot2.card.data.type)
			distill_slot1.card.queue_free()
			distill_slot2.card.queue_free()
		elif distill_slot1.has_card() && distill_slot1.card.data.category == Constants.CATEGORY.UPGRADE:
			distill_upgrade_multiplier += 1
			distill_level += 1
			apply_distill_upgrade()
			distill_slot1.card.queue_free()
		elif distill_slot2.has_card() && distill_slot2.card.data.category == Constants.CATEGORY.UPGRADE:
			distill_upgrade_multiplier += 1
			distill_level += 1
			apply_distill_upgrade()
			distill_slot2.card.queue_free()

func apply_refine_upgrade():
	refine_level_label.text = "Lv " + str(refine_level)
	match refine_level:
		2:
			free_refine_cap = 1

func apply_distill_upgrade():
	distill_level_label.text = "Lv " + str(distill_level)
	match distill_level:
		2:
			free_distill_cap = 1

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
	summary_page.hide()
	event_page.hide()
	_game_over_screen.show()

func _on_return_to_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")

func _on_next_turn_button_pressed():
	summary_page.hide()
	
	var turn_event = ContentFactory.generate_turn_event(turn)
	if turn_event != null:
		assign_turn_event(turn_event)
	else:
		next_turn()

func assign_turn_event(event:TurnEvent):
	current_event = event
	event_title_label.text = event.title
	event_contents_label.text = event.content
	event_options1_button.text = event.button_text1
	if !event.button_text2.is_empty():
		event_options2_button.text = event.button_text2
		event_options2_button.show()
	else:
		event_options2_button.hide()
	if !event.button_text3.is_empty():
		event_options3_button.text = event.button_text3
		event_options3_button.show()
	else:
		event_options3_button.hide()
	event_page.show()

func _on_option_button_1_pressed():
	event_page.hide()
	process_event(current_event.event_type, current_event.card1, current_event.value1)
	next_turn()

func _on_option_button_2_pressed():
	event_page.hide()
	process_event(current_event.event_type, current_event.card2, current_event.value2)
	next_turn()

func _on_option_button_3_pressed():
	event_page.hide()
	process_event(current_event.event_type, current_event.card3, current_event.value3)
	next_turn()

func process_event(type:Constants.EVENT_TYPE, card_data:CardData, value: int):
	match type:
		Constants.EVENT_TYPE.ADD_CARD:
			next_draw_cards.push_back(card_data)
		Constants.EVENT_TYPE.ADJUST_TAX:
			set_tax(tax + value)
