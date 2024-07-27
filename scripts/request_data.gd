class_name RequestData

var name: String
var item: Constants.ID
var gold: int

static func create(name: String, item:Constants.ID, gold):
	var request = RequestData.new()
	request.name = name
	request.item = item
	request.gold = gold
	return request
