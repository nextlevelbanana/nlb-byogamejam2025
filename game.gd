extends Node2D


const Main = preload("res://grid.tscn")
var MainScene

const GameOverConst = preload("res://game_over.tscn")
var GameOverScene : GameOver

const AllHats = preload("res://all_hats.tscn")
var AllHatsScene

const Scoreboard = preload("res://UI/scoreboard.tscn")
var ScoreboardScene

var score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MainScene = Main.instantiate()
	GameOverScene = GameOverConst.instantiate()
	AllHatsScene = AllHats.instantiate()
	ScoreboardScene = Scoreboard.instantiate()
	SignalBus.connect("game_started", _on_game_started)
	SignalBus.connect("game_over", _on_game_over)
	SignalBus.connect("all_hats", _on_all_hats)
	
	SignalBus.connect("on_score_changed", _on_score_changed)
	SignalBus.connect("on_restart_game", _on_restart_game)
	
func _on_score_changed(points: int) -> void:
	score += points

func _on_game_started():
	score = 0
	add_child(ScoreboardScene)
	add_child(MainScene)
	#$Label.visible = true
#	$Title.queue_free()
			
func _on_game_over():
	#GameOverScene.score = score
	GameOverScene.score = score
	add_child(GameOverScene)
	
	MainScene.queue_free()
	AllHatsScene.queue_free()
	ScoreboardScene.queue_free()
	
func _on_all_hats():
	AllHatsScene.position = Vector2( int(1900/2), int(1080 * .667))
	add_child(AllHatsScene)
	await get_tree().create_timer(2.0).timeout
	_on_game_over()
	
func _on_restart_game() -> void :
	GameOverScene.queue_free()
	
	MainScene = Main.instantiate()
	GameOverScene = GameOverConst.instantiate()
	AllHatsScene = AllHats.instantiate()
	ScoreboardScene = Scoreboard.instantiate()
