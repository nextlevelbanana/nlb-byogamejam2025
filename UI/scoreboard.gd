extends Control

@export var scoreLabel : RichTextLabel

var TextFx = preload("res://text_fx.tscn")

const WINNING_SCORE : int = 87
@export var score : int = 0

var score_increment: int = 0
var score_multiplier: float = 0.0

var scoreIncrementUI = preload("res://score_increment_ui.tscn")
var scoreMultUI = preload("res://score_mult_ui.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _set_score_text()

    AudioSignalBus.connect("play_match_made", _play_match_made)
    SignalBus.connect("top_hat_made", score_top_hat)
    SignalBus.connect("top_hat_made", _play_hat_complete)
    SignalBus.connect("bad_hat_made", play_judgy_abe)
    SignalBus.connect("bad_hat_made", score_bad_hat)
    SignalBus.connect("match_made", score_match)
    SignalBus.connect("game_over_timer", _on_game_time_timeout)
    SignalBus.connect("increase_score_multiplier", _on_increase_score_multiplier)
    SignalBus.connect("scoring_events_finished", _handle_scoring_event)
    # register for scoring events


func _set_score_text() -> void:
    scoreLabel.text = "[wave][rainbow]" + str(score) + "[/rainbow][/wave]"

func increase_score_increment(amount):
    score_increment += amount
    var scoreUI = scoreIncrementUI.instantiate()
    scoreUI.ui_text = amount
    add_child(scoreUI)
    
func _on_increase_score_multiplier(amount):
    score_multiplier += amount
    if score_multiplier > 1:
        var multUI = scoreMultUI.instantiate()
        multUI.ui_text = amount
        add_child(multUI)
    
func reset_score_calculators():
    score_increment = 0
    score_multiplier = 0.0
    
func score_top_hat(height):
    var amount
    if height == 3:
        amount = 1000
    if height == 4:
        amount = 3000
    if height == 5:
        amount = 8000
    increase_score_increment(amount)

func score_bad_hat():
    increase_score_increment(50)
    
func score_match(length):
    var amount
    if length == 3:
        amount = 10
    if length == 4:
        amount = 30
    if length == 5:
        amount = 100
    increase_score_increment(amount)

func _handle_scoring_event() -> void:
    var points = score_increment * score_multiplier
    score += int(points)
    
    SignalBus.on_score_changed.emit(points)
    
    _set_score_text()
    reset_score_calculators()
    
    if( score > WINNING_SCORE ):
        #fire a GAME OVER: WIN signal
        pass	
    
    
func _play_match_made() -> void:
    # Taking this out for now.  Maybe fun later if needed?
    #var textFx = TextFx.instantiate()
    #textFx.set_text("Woof!", 0)
    #add_child(textFx)
    
    #AudioSignalBus.play_match_made.emit()
    #_handle_scoring_event()
    pass

func play_judgy_abe() -> void:
    var textFx = TextFx.instantiate()
    textFx.set_text("I DISAPPROVE OF THIS HAT.", 1)
    textFx.position = Vector2(1360, 700)
    add_child(textFx)

    AudioSignalBus.play_sad_pitch.emit()

    AudioSignalBus.play_bad_hat_drop.emit()

func _play_hat_complete(_height) -> void:
    var textFx = TextFx.instantiate()
    textFx.position = Vector2(1360, 700)
    textFx.set_text("Four score and Seven points for that hat!", 2)
    add_child(textFx)

    AudioSignalBus.play_hat_complete.emit()

func _on_game_time_timeout():
    SignalBus.game_over.emit()
