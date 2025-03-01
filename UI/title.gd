extends Node2D

@export var title : RichTextLabel
@export var menu : RichTextLabel

var is_launching_game : bool = false
var Credits = preload("res://UI/credits.tscn")
var creditsInstance
var areCreditsUp = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	SignalBus.connect("on_restart_game", on_restart_game)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	pass

func _unhandled_key_input(event: InputEvent) -> void:
	if( areCreditsUp ):
		return
		
	if event is InputEventKey and event.is_pressed() and !event.is_echo():
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		else:
			if( !is_launching_game ):
				is_launching_game = true
				AudioSignalBus.play_button_click.emit()
				_bounce_titles()

func _bounce_titles() :
	var tween = create_tween()
	tween.parallel().tween_property(title, "position", Vector2(title.position.x, title.position.y-700), 2).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(menu, "position", Vector2(menu.position.x, menu.position.y+700), 2).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(_titles_bounced)

func _bounce_titles_out() :
	var tween = create_tween()
	tween.parallel().tween_property(title, "position", Vector2(title.position.x, title.position.y-700), 2).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(menu, "position", Vector2(menu.position.x, menu.position.y+700), 2).set_trans(Tween.TRANS_ELASTIC)

func _bounce_titles_in() :
	var tween = create_tween()
	tween.parallel().tween_property(title, "position", Vector2(title.position.x, title.position.y+700), 2).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(menu, "position", Vector2(menu.position.x, menu.position.y-700), 2).set_trans(Tween.TRANS_ELASTIC)

func _titles_bounced() :
	SignalBus.game_started.emit()

func _on_credits_button_pressed() -> void:
	_bounce_titles_out()
	areCreditsUp = true
	SignalBus.connect("close_credits", _on_close_credits)
	creditsInstance = Credits.instantiate()
	add_child(creditsInstance)
	
func _on_close_credits() -> void:
	areCreditsUp = false
	creditsInstance.queue_free()
	_bounce_titles_in()
	
func on_restart_game() -> void:
	is_launching_game = false
	_bounce_titles_in()
