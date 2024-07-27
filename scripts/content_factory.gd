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
	return info

static func get_random_material():
	var roll = randf_range(0,1)
	if roll > 0.5:
		return Constants.ID.HERB_MANA
	else:
		return Constants.ID.HERB_HEALTH

static func generate_cards(turn:int):
	var cards: Array[Card]
	if turn == 1:
		cards.push_back(Card.create(create_card_data(Constants.ID.HERB_HEALTH)))
		cards.push_back(Card.create(create_card_data(Constants.ID.HERB_HEALTH)))
	if turn == 2:
		cards.push_back(Card.create(create_card_data(Constants.ID.HERB_MANA)))
		cards.push_back(Card.create(create_card_data(Constants.ID.HERB_MANA)))
	if turn >= 3:
		for i in 3:
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
