extends Node2D

@export var title : RichTextLabel
@export var credits : RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_bounce_titles_in()


func _bounce_titles_in() :
	var tween = create_tween()
	tween.parallel().tween_property(title, "position", Vector2(title.position.x, title.position.y+500), 2).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(credits, "position", Vector2(credits.position.x, credits.position.y-700), 2).set_trans(Tween.TRANS_ELASTIC)

func _bounce_titles_out() :
	var tween = create_tween()
	tween.parallel().tween_property(title, "position", Vector2(title.position.x, title.position.y-500), 2).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(credits, "position", Vector2(credits.position.x, credits.position.y+700), 2).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(_titles_bounced)

func _on_back_button_pressed() -> void:
	_bounce_titles_out()
	
func _titles_bounced() -> void:
	SignalBus.close_credits.emit()
	
	
