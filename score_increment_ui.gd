extends Node2D

var ui_text


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(randi_range(100,300), randi_range(350,600)) #Vector2(randi_range(1300,1800), randi_range(200,880))
	rotation_degrees = [-15, 15].pick_random()
	show_increment()


func show_increment():
	$container.text = "+ %s!" % ui_text
	var tween = create_tween()
	tween.parallel().tween_property($container, "scale", Vector2(1.5,1.5), 0.5)
	await tween.finished
	queue_free()
	
