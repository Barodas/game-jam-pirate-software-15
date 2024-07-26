class_name CardData

var name: String
var category: Constants.CATEGORY
var type: Constants.TYPE
var energy: int
var gold: int

static func create(name:String, category:Constants.CATEGORY, type:Constants.TYPE, energy, gold):
	var card = CardData.new()
	card.name = name
	card.category = category
	card.type = type
	card.energy = energy
	card.gold = gold
	return card

# Could maybe change this to be a single id with functions that return for name, energy, etc
