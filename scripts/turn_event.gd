class_name TurnEvent

var title: String
var content: String
var button_text1: String
var button_text2: String
var button_text3: String

static func create(title:String, content:String, button1:String, button2:String = "", button3:String = ""):
	var event = TurnEvent.new()
	event.title = title
	event.content = content
	event.button_text1 = button1
	event.button_text2 = button2
	event.button_text3 = button3
	return event
