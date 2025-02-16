extends Node2D

var kind 
var isLocked = false
var row
var col

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_kind(newKind):
	kind = newKind
	$Symbol.animation = newKind
	
func set_pos(row, column):
	row = row
	col = column
	position = Vector2(Constants.GRID_ORIGIN.x + (row * Constants.CELL_SIZE), Constants.GRID_ORIGIN.y + (col * Constants.CELL_SIZE))

func update_lock(newState):
	isLocked = newState
