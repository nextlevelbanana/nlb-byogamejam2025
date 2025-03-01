extends Node2D


const Main = preload("res://grid.tscn")
var MainScene

const GameOver = preload("res://game_over.tscn")
var GameOverScene

var score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MainScene = Main.instantiate()
	GameOverScene = GameOver.instantiate()
	SignalBus.connect("game_started", _on_game_started)
	SignalBus.connect("game_over", _on_game_over)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_game_started():
	score = 0
	add_child(MainScene)
	$Label.visible = true
	$Title.queue_free()
			
func _on_game_over():
	add_child(GameOverScene)
	MainScene.queue_free()
	
	
