extends ParallaxBackground

@onready var parallax_speed: int = 50

func _process(delta: float) -> void:
	scroll_offset.x -= parallax_speed * delta
