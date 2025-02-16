extends Node2D

var cell_state = []
var Cell = preload("res://cell.tscn")

func _ready() -> void:
	$Cursor.position = Constants.GRID_ORIGIN
	initialize_grid()

func _process(delta: float) -> void:
	pass
	
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.is_action_pressed("move_right"):
			$Cursor.position.x = min($Cursor.position.x + Constants.CELL_SIZE, Constants.RIGHTMOST_COLUMN_LEFT_X)
		elif event.is_action_pressed("move_left"):
			$Cursor.position.x = max(Constants.GRID_ORIGIN.x, $Cursor.position.x - Constants.CELL_SIZE)
		elif event.is_action_pressed("move_down"):
			$Cursor.position.y = min($Cursor.position.y + Constants.CELL_SIZE, Constants.BOTTOM_ROW_TOP_Y)
		elif event.is_action_pressed("move_up"):
			$Cursor.position.y = max(Constants.GRID_ORIGIN.y, $Cursor.position.y - Constants.CELL_SIZE)
		
func initialize_grid():
	for i in Constants.GRID_SIZE:
		cell_state.push_back([])
	
	for column in Constants.GRID_SIZE:
		for row in Constants.GRID_SIZE:
			var this_cell = Constants.KINDS.pick_random()
			cell_state[row].append(this_cell)
			var newCell = Cell.instantiate()
			newCell.set_pos(row, column)
			newCell.update_kind(this_cell)
			add_child(newCell)
			
	print(cell_state)
