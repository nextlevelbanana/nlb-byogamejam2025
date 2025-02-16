extends Node2D


const Main = preload("res://grid.tscn")
var MainScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MainScene = Main.instantiate()
	SignalBus.connect("game_started", _on_game_started)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_game_started():
	add_child(MainScene)
	$Title.queue_free()
			
	
	
