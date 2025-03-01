extends Control

@export var scoreLabel : RichTextLabel

var TextFx = preload("res://text_fx.tscn")

const WINNING_SCORE : int = 87
@export var score : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_score_text()

	AudioSignalBus.connect("play_match_made", _play_match_made)
	SignalBus.connect("top_hat_made", _play_hat_complete)
	SignalBus.connect("bad_hat_made", play_judgy_abe)
	SignalBus.connect("game_over_timer", _on_game_time_timeout)

	# register for scoring events


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_score_text() -> void:
	scoreLabel.text = "[wave][rainbow]" + str(score) + "[/rainbow][/wave]"

func _handle_scoring_event(points:int) -> void:
	score += points
	
	SignalBus.on_score_changed.emit(points)
	
	_set_score_text()
	
	if( score > WINNING_SCORE ):
		#fire a GAME OVER: WIN signal
		pass	
	
func _play_match_made() -> void:
	# Taking this out for now.  Maybe fun later if needed?
	#var textFx = TextFx.instantiate()
	#textFx.set_text("Woof!", 0)
	#add_child(textFx)
	
	#AudioSignalBus.play_match_made.emit()
	_handle_scoring_event(2)

func play_judgy_abe() -> void:
	var textFx = TextFx.instantiate()
	textFx.set_text("I DISAPPROVE OF THIS HAT.", 1)
	textFx.position = Vector2(1360, 700)
	add_child(textFx)

	AudioSignalBus.play_sad_pitch.emit()

	AudioSignalBus.play_bad_hat_drop.emit()
	_handle_scoring_event(2)

func _play_hat_complete() -> void:
	var textFx = TextFx.instantiate()
	textFx.position = Vector2(1360, 700)
	textFx.set_text("Four score and Seven points for that hat!", 2)
	add_child(textFx)

	AudioSignalBus.play_hat_complete.emit()
	_handle_scoring_event(8)

func _on_game_time_timeout():
	SignalBus.game_over.emit()
