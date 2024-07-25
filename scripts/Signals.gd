extends Node

# Example Signal
#signal example_signal(amount: float, counter: int)
# Example Connect
#func _on_receive_example_signal(amount, counter):
#	pass
#Signals.example_signal.connect(_on_receive_example_signal)
# Example Send
#Signals.example_signal.emit(val, 0)

signal select_card(card: Card)
signal click_slot(slot: Slot)
