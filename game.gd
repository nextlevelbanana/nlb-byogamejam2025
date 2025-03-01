extends Node2D


const Main = preload("res://grid.tscn")
var MainScene

const GameOver = preload("res://game_over.tscn")
var GameOverScene

const AllHats = preload("res://all_hats.tscn")
var AllHatsScene

var score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MainScene = Main.instantiate()
	GameOverScene = GameOver.instantiate()
	AllHatsScene = AllHats.instantiate()
	SignalBus.connect("game_started", _on_game_started)
	SignalBus.connect("game_over", _on_game_over)
	SignalBus.connect("all_hats", _on_all_hats)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_game_started():
	score = 0
	add_child(MainScene)
	#$Label.visible = true
#	$Title.queue_free()
			
func _on_game_over():
	#GameOverScene.score = score
	add_child(GameOverScene)
	MainScene.queue_free()
	AllHatsScene.queue_free()
	
func _on_all_hats():
	AllHatsScene.position = Vector2( 1900/2, 1080 * .667)
	add_child(AllHatsScene)
	await get_tree().create_timer(2.0).timeout
	_on_game_over()
	
	
