extends ParallaxBackground

@onready var parallax_speed: int = 50

# credit for the images (in case they wind up shipping)
# https://opengameart.org/content/seamless-hd-landscape-in-parts

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scroll_offset.x -= parallax_speed * delta
