class_name RequestData

var name: String
var type: Constants.TYPE
var gold: int
var renown: int
var duration: int

static func create(name: String, type:Constants.TYPE, gold:int, renown:int, duration:int):
	var request = RequestData.new()
	request.name = name
	request.type = type
	request.gold = gold
	request.renown = renown
	request.duration = duration
	return request
