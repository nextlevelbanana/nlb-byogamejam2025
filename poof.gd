extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioSignalBus.play_match_made.emit()

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
