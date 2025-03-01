extends Node2D

@export var title : RichTextLabel
@export var menu : RichTextLabel

var is_launching_game : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	pass

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and !event.is_echo():
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		else:
			AudioSignalBus.play_button_click.emit()
			_bounce_titles()

func _bounce_titles() :
	var tween = create_tween()
	tween.parallel().tween_property(title, "position", Vector2(title.position.x, title.position.y-700), 2).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(menu, "position", Vector2(menu.position.x, menu.position.y+700), 2).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(_titles_bounced)

func _titles_bounced() :
	SignalBus.game_started.emit()
