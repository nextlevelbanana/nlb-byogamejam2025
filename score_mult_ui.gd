extends Node2D

var ui_text


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(randi_range(100,300), randi_range(500,700)) #Vector2(randi_range(1300,1800), randi_range(200,880))
	rotation_degrees = [-15, 15].pick_random()
	show_mult()


func show_mult():
	$mult_ui.text = "[rainbow]x %s[/rainbow]" % ui_text
	var tween = create_tween()
	tween.parallel().tween_property($mult_ui, "scale", Vector2(2.5, 2.5), 0.8)
	await tween.finished
	queue_free()
	
