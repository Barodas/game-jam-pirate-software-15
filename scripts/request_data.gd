class_name RequestData

var name: String
var type: Constants.TYPE
var gold: int
var renown: int

static func create(name: String, type:Constants.TYPE, gold:int, renown:int):
	var request = RequestData.new()
	request.name = name
	request.type = type
	request.gold = gold
	request.renown = renown
	return request
