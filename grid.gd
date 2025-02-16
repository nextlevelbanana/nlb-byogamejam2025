extends Node2D

var cells = []
var preview_cells = []
var Cell = preload("res://cell.tscn")

var firstSelected
var secondSelected

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
		elif event.is_action_pressed("confirm"):
			tryConfirmSelection()
		
#I feel good about this one, I think the grid is initializing correctly
func initialize_grid():
	#create empty child arrays, one per row
	for i in Constants.GRID_SIZE:
		cells.push_back([])
	
	for row in Constants.GRID_SIZE:
		for column in Constants.GRID_SIZE:
			#new cell setup, only happens once per game
			#(its kind will be updated as pieces move)
			#instantiate them all and add them to the tree
			var this_cell = Constants.KINDS.pick_random()
			var newCell = Cell.instantiate()
			newCell.set_pos(row, column)
			newCell.update_kind(this_cell)
			newCell.add_to_group("cells")
			add_child(newCell)
			cells[row].append(newCell)
			
	#create and fill the preview cells
	# and add them to the scene
	for column in Constants.GRID_SIZE:
		var preview = Constants.KINDS.pick_random()
		preview_cells.append(preview)
		var newCell = Cell.instantiate()
		newCell.set_pos(-1, column)
		newCell.update_kind(preview)
		newCell.add_to_group("previews")
		add_child(newCell)
		
	clean_up_initial_cell_state()
	

#cautiously optimistic that this is working
#I suppose a weird initial state isn't the WORST thing in the world, if it's wrong
func clean_up_initial_cell_state():
	
	var hats = get_new_completed_hats()
	var matches = get_matches()
	
	while hats.size() || matches.size():
		#find and change any initial hats on the bottom row
		# or completed top hats on the bottom row
		for hatColumn in hats:
			cells[Constants.GRID_SIZE - 1][hatColumn].update_kind(Constants.NON_HATS.pick_random())
	
	# find and change any initial groups of 3
		if matches.size():
			for m in matches:
				cells[m.pick_random().y][m.pick_random().x].update_kind(Constants.KINDS.pick_random())
				
	#check again to see if we've introduced new problems
		hats = get_new_completed_hats()
		matches = get_matches()
			
#this is working
func tryConfirmSelection():
	var cell_pos = getCell($Cursor.position)
	print(cell_pos)
	if !firstSelected:
		firstSelected = cells[cell_pos.y][cell_pos.x]
		print(firstSelected.kind)
		$FirstSelection.position = $Cursor.position
		$FirstSelection.visible = true
	else:
		#selecting the same cell twice un-selects it
		if (firstSelected.grid_pos.y == cell_pos.y && firstSelected.grid_pos.x == cell_pos.x):
			reset_cursors()
		elif cell_pos.distance_to(firstSelected.grid_pos) > 1:
			#todo: play WRONG buzzer, shake, etc
			print("too far away")
			#pass
		else:
			secondSelected = cells[cell_pos.y][cell_pos.x]
			print("swapping!")
			swap()

#this is working
func getCell(cursor_pos):
	return Vector2((cursor_pos.x - Constants.GRID_ORIGIN.x) / Constants.CELL_SIZE, (cursor_pos.y - Constants.GRID_ORIGIN.y) / Constants.CELL_SIZE)
	
#this is working
func swap():
	var tmp = firstSelected.kind
	var tmp2 = secondSelected.kind

	cells[firstSelected.grid_pos.y][firstSelected.grid_pos.x].update_kind(tmp2)
	cells[secondSelected.grid_pos.y][secondSelected.grid_pos.x].update_kind(tmp)
	
	reset_cursors()
	
#this is working
func reset_cursors():
	firstSelected = null
	secondSelected = null
	$FirstSelection.visible = false
	$SecondSelection.visible = false
	

#this is working
func refill_preview_cells():
	for preview in get_tree().get_nodes_in_group("previews"):
		if !preview.kind:
			preview.update_kind(Constants.KINDS.pick_random())
		
	
#returns an array of lists of coordinates of all the matches on the grid
#cautiously optimistic this is working as well
func get_matches():
	var matches = []
	#find all horizontal matches
	for y in Constants.GRID_SIZE:
		var x = 0
		var current_match = [ ]

		while x < Constants.GRID_SIZE - 2:
			var candidate = cells[y][x].kind
			print("%s %s %s" % [y, x, candidate])
			if cells[y][x+1].kind == candidate && cells[y][x+2].kind == candidate:
				#found a match!
				current_match.push_back(Vector2(x,y),)
				current_match.push_back(Vector2(x+1, y))
				current_match.push_back(Vector2(x+2, y))
				print("match found at %s" % x)
				x = x +3
				#need to check for matches of length 4+
				while x < Constants.GRID_SIZE && candidate == cells[y][x].kind:
					current_match.push_back(Vector2(x,y))
					x = x + 1
				#found the end of the match in this row, add it to the grand total
				matches.push_back(current_match)
			else: # not a triad, check the next column
				print("no match at %s"%x)
				x = x + 1

	#todo: find all vertical matches
	for x in Constants.GRID_SIZE:
		var y = 0
		var current_match = [ ]

		while y < Constants.GRID_SIZE - 2:
			var candidate = cells[y][x].kind
			print("%s %s %s" % [y, x, candidate])
			if cells[y+1][x].kind == candidate && cells[y+2][x].kind == candidate:
				#found a match!
				current_match.push_back(Vector2(x,y),)
				current_match.push_back(Vector2(x, y+1))
				current_match.push_back(Vector2(x, y+2))
				print("match found at %s" % y)
				y = y +3
				#need to check for matches of length 4+
				while y < Constants.GRID_SIZE && candidate == cells[y][x].kind:
					current_match.push_back(Vector2(x,y))
					y = y + 1
				#found the end of the match in this row, add it to the grand total
				matches.push_back(current_match)
			else: # not a triad, check the next column
				print("no match at %s"%y)
				y = y + 1

	return matches
				

# returns the column indexes that have new completed hats
#I feel good about this one
func get_new_completed_hats():
	var hat_matches = []
	for column in Constants.GRID_SIZE:
		var current_cell = cells[Constants.GRID_SIZE - 1][column]
		if !current_cell.isLocked && current_cell.isHat:
			if get_completed_top_hat(column).size() || !current_cell.isTopHat:
				hat_matches.push_back(column)
	return hat_matches

# assumes column is unlocked
# returns the coords of all top hat pieces, or an empty array if hat incomplete, in a given column
func get_completed_top_hat(col):
	var top_hat_pieces = []
	if (cells[Constants.GRID_SIZE - 1][col].kind == "hatBottom"
		&& cells[Constants.GRID_SIZE - 2][col].kind == "hatMid"):
			if (cells[Constants.GRID_SIZE - 3][col].kind == "hatTop"):
				top_hat_pieces.push_back([Vector2(col, Constants.GRID_SIZE - 1), Vector2(col, Constants.GRID_SIZE - 2), Vector2(col, Constants.GRID_SIZE - 3)])
			else:
				pass
				#todo: extend this logic to check for taller hats
				#todo: do we want to accept a 2-score hat?
	return top_hat_pieces
