extends Control

@export var scoreLabel : RichTextLabel

var TextFx = preload("res://text_fx.tscn")

const WINNING_SCORE : int = 87
var score : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_score_text()
	# register for scoring events


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_score_text() -> void:
	scoreLabel.text = "[wave][rainbow]" + str(score) + "[/rainbow][/wave]"

func _handle_scoring_event(points:int) -> void:
	score += points
	_set_score_text()
	
	if( score > WINNING_SCORE ):
		#fire a GAME OVER: WIN signal
		pass	
	
func _on_object_match_button_pressed() -> void:
	var textFx = TextFx.instantiate()
	textFx.set_text("Woof!", 0)
	add_child(textFx)
	
	AudioSignalBus.play_match_made.emit()
	_handle_scoring_event(2)

func _on_small_hat_button_pressed() -> void:
	var textFx = TextFx.instantiate()
	textFx.set_text("I DISAPPROVE OF THIS HAT.", 1)
	textFx.position = Vector2(1120, 120)
	add_child(textFx)

	AudioSignalBus.play_sad_pitch.emit()

	AudioSignalBus.play_bad_hat_drop.emit()
	_handle_scoring_event(2)

func _on_top_hat_button_pressed() -> void:
	var textFx = TextFx.instantiate()
	textFx.position = Vector2(1120, 120)
	textFx.set_text("Four score and Seven points for that hat!", 2)
	add_child(textFx)

	AudioSignalBus.play_hat_complete.emit()
	_handle_scoring_event(8)
