extends Node2D

class_name GameOver

@export var score : int

var scoreTextTemplate : String = "[center][wave]You scored [rainbow]%s[/rainbow] points![/wave][/center]"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FinalScore.text = scoreTextTemplate % score
	
	if( score < 40 ):
		_play_sad_lincoln()
	elif( score >= 87 ):
		_play_stoked_lincoln()
	else:
		_play_basic_lincoln()
		
func _play_sad_lincoln() -> void:
	$AbeSays.text = "[center][shake]\"Why, I believe you could do better.\"[/shake][/center]"
	$Lincoln._on_bad_hat_made()
	
func _play_basic_lincoln() -> void:
	$AbeSays.text = "[center][wave]\"That'll do, I say.  That'll do.\"[/wave][/center]"
	$Lincoln._on_top_hat_made()
	pass
	
func _play_stoked_lincoln() -> void:
	$AbeSays.text = "[center][wave][rainbow]\"I declare this to be a fine collection of hats!\"[/rainbow][/wave][/center]"
	$Lincoln._on_top_hat_made()
	pass


func _on_menu_menu_button_pressed() -> void:
	SignalBus.on_restart_game.emit()
