extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("top_hat_made", _on_top_hat_made)
	SignalBus.connect("bad_hat_made", _on_bad_hat_made)


func _on_top_hat_made(_height):
	play("happy");
	
func _on_bad_hat_made(): 
	play("mad")

func _on_animation_finished() -> void:
	if animation == "happy" || animation == "mad":
		play("default")
