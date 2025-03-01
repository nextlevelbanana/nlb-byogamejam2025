extends Node2D

@export var label : RichTextLabel

var timer : float = 180.0
const PANIC_TIME : float = 60.0

var isPanic : bool = false

func _process(delta: float) -> void:
	timer -= delta
	
	_update_timer()
	
	if( timer <= PANIC_TIME && !isPanic ):
		_panic_time()
		
	if( timer <= 0.0 ) :
		_game_over_man()
		
	pass
	
func _update_timer() -> void:
	var sec = fmod(timer, 60)
	var min = timer / 60
	var formatString = "%02d : %02d"
	
	var actualString = "[center]"
	
	if( isPanic ):
		actualString += "[shake]"

	if( timer < 10.0 ):
		actualString += "[pulse]"
	
	actualString += formatString % [min, sec]	

	if( timer < 10.0 ):
		actualString += "[/pulse]"

	if( isPanic ):
		actualString += "[/shake]"

	actualString += "[/center]"
	
	label.text = actualString
	
func _panic_time() -> void:
	isPanic = true
	AudioSignalBus.play_fast_pitch.emit()

func _game_over_man() -> void:
	SignalBus.game_over_timer.emit()
