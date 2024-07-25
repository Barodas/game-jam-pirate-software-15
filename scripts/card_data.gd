class_name CardData

var name: String
var energy: int
var gold: int

static func create(name, energy, gold):
	var card = CardData.new()
	card.name = name
	card.energy = energy
	card.gold = gold
	return card

# Could maybe change this to be a single id with functions that return for name, energy, etc
