class_name TurnEvent

var event_type: Constants.EVENT_TYPE
var title: String
var content: String
var button_text1: String
var button_text2: String
var button_text3: String

# Result info (these are used based on event_type
var card1: CardData
var card2: CardData
var card3: CardData

static func create(type:Constants.EVENT_TYPE, title:String, content:String, button1:String, button2:String = "", button3:String = "", card1 = null, card2 = null, card3 = null):
	var event = TurnEvent.new()
	event.event_type = type
	event.title = title
	event.content = content
	event.button_text1 = button1
	event.button_text2 = button2
	event.button_text3 = button3
	event.card1 = card1
	event.card2 = card2
	event.card3 = card3
	return event
