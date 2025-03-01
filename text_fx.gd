extends Node2D

@export var label: RichTextLabel

var timer : float = 2;

func _process(delta: float) -> void:
	timer -= delta
	if( timer <= 0.0 ):
		queue_free()
	pass
	
func set_text(text: String, type: int):
	var tempText: String = "[center]\n"
	
	if( type == 0 ):
		tempText += "[tornado]"
	if( type == 1 ):
		tempText += "[shake]"
	if( type == 2 ):
		tempText += "[rainbow]"
	
	tempText += text

	if( type == 0 ):
		tempText += "[/tornado]"
	if( type == 1 ):
		tempText += "[/shake]"
	if( type == 2 ):
		tempText += "[/rainbow]"

	tempText += "\n[/center]"
	label.text = tempText
