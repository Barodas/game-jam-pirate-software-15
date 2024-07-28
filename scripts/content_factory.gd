class_name ContentFactory

static func create_card_data(type: Constants.ID):
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
		Constants.ID.UPGRADE_REFINE:
			info = CardData.create("Refining\nStation\nUpgrade",Constants.CATEGORY.UPGRADE,
			 Constants.TYPE.UPGRADE_REFINE, 1, 10)
		Constants.ID.UPGRADE_DISTILL:
			info = CardData.create("Distilling\nStation\nUpgrade",Constants.CATEGORY.UPGRADE,
			 Constants.TYPE.UPGRADE_DISTILL, 1, 10)
	return info

static func get_random_material():
	var roll = randf_range(0,1)
	if roll > 0.5:
		return Constants.ID.HERB_MANA
	else:
		return Constants.ID.HERB_HEALTH

static func generate_cards(turn:int, amount:int, reserved_draws:Array[CardData]):
	var cards: Array[Card]
	if turn == 1:
		cards.push_back(Card.create(create_card_data(Constants.ID.HERB_HEALTH)))
		cards.push_back(Card.create(create_card_data(Constants.ID.HERB_HEALTH)))
	if turn == 2:
		cards.push_back(Card.create(create_card_data(Constants.ID.HERB_MANA)))
		cards.push_back(Card.create(create_card_data(Constants.ID.HERB_MANA)))
	if turn >= 3:
		for data in reserved_draws:
			cards.push_back(Card.create(data))
		var random_draws = amount - reserved_draws.size()
		for i in random_draws:
			cards.push_back(Card.create(create_card_data(get_random_material())))
	return cards

static func get_random_request():
	var roll = randf_range(0,1)
	if roll > 0.6:
		return RequestData.create("Health Potion", Constants.TYPE.HEALTH, 4, 10)
	elif roll > 0.2:
		return RequestData.create("Mana Potion", Constants.TYPE.MANA, 6, 10)
	else:
		return RequestData.create("Stamina Potion", Constants.TYPE.STAMINA, 10, 20)

static func generate_requests(turn:int):
	var requests: Array[RequestData]
	if turn == 1:
		requests.push_back(RequestData.create("Health Potion", Constants.TYPE.HEALTH, 5, 10))
	if turn == 2:
		requests.push_back(RequestData.create("Mana Potion", Constants.TYPE.MANA, 5, 10))
	if turn >= 3:
		for i in 2:
			requests.push_back(get_random_request())
	return requests

static func generate_turn_event(turn:int):
	if turn == 0:
		return TurnEvent.create(Constants.EVENT_TYPE.INFO, "Opening Day!", 
			"""It's taken a lot of work but the day is finally here.
			
			Refine MATERIALS into REAGENTS, then Distill them into
			a POTION. Place the Potion in the Requests slot and
			END TURN to turn it in.""", "Got it!")
	if turn == 1:
		return TurnEvent.create(Constants.EVENT_TYPE.INFO, "More variety!", 
		"""There's more to alchemy than just Health Potions. 
		Blue Herbs can be refined into a dust for creating 
		Mana Potions.
		
		Customers can't tell at a glance what your potion does. 
		While you CAN sell them something different to what they 
		asked for, it will have a negative effect on your 
		reputation (RENOWN).
		
		Alchemists with a good reputation will attract higher 
		paying customers!""", "Got it!")
	if turn == 2:
		return TurnEvent.create(Constants.EVENT_TYPE.ADD_CARD, "Upgrades!", 
		"""Sometimes you will find a MATERIAL that can be used to upgrade 
		a part of your shop. These upgrades can do things like provide a 
		free craft each turn, or a chance to create additional outputs.
		
		The cost can be steep, but the benefit will pay off over later turns.""", 
		"I think I'll upgrade the Refining Station", 
		"The Distilling Station could use an upgrade", "", 
		create_card_data(Constants.ID.UPGRADE_REFINE), 
		create_card_data(Constants.ID.UPGRADE_DISTILL))
	return null
