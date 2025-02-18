extends Node2D

var kind 
var isLocked = false
var grid_pos
var isHat = false
var isTopHat = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_kind(newKind):
	kind = newKind
	if !newKind:
		$Symbol.visible = false
	else:
		$Symbol.animation = newKind
	isHat = newKind in Constants.ALL_HATS
	isTopHat = newKind in ["hatTop", "hatMid", "hatBottom"]		
	
func set_pos(row, column):
	# I am continually getting confused by the fact that row is the y coord in the Vector2
	#but it is. I promise
	grid_pos = Vector2(column, row) 
	position = Vector2(Constants.GRID_ORIGIN.x + (column * Constants.CELL_SIZE), Constants.GRID_ORIGIN.y + (row * Constants.CELL_SIZE))

func update_lock(newState):
	isLocked = newState
	if isLocked:
		$Symbol.modulate = "#3097b3"
