extends Node2D

var cells = []
var preview_cells = []
var Cell = preload("res://cell.tscn")

var firstSelected
var secondSelected

var hats_complete = 0

func _ready() -> void:
	$Cursor.position = Constants.GRID_ORIGIN
	initialize_grid()
	SignalBus.connect("swap_selected", _on_swap_selected)

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
	if !firstSelected :
		firstSelected = cells[cell_pos.y][cell_pos.x]
		if !firstSelected.isLocked:
			$FirstSelection.position = $Cursor.position
			$FirstSelection.visible = true
		#todo: an else to indicate you can't select a locked hat
	else:
		#selecting the same cell twice un-selects it
		if (firstSelected.grid_pos.y == cell_pos.y && firstSelected.grid_pos.x == cell_pos.x):
			reset_cursors()
		elif cell_pos.distance_to(firstSelected.grid_pos) > 1:
			#todo: play WRONG buzzer, shake, etc
			print("too far away")
			#pass
		elif cells[cell_pos.y][cell_pos.x].isLocked:
			pass #todo: indicate you can't select a locked hat
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
	SignalBus.swap_selected.emit()

	
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
			var candidate = cells[y][x]
			var next_cell = cells[y][x+1]
			var third_cell = cells[y][x+2]
			
			if (!candidate.isLocked && 
					!next_cell.isLocked && next_cell.kind == candidate.kind &&
						 !third_cell.isLocked && third_cell.kind == candidate.kind):
				#found a match!
				current_match.push_back(Vector2(x,y),)
				current_match.push_back(Vector2(x+1, y))
				current_match.push_back(Vector2(x+2, y))
				print("match found at %s" % x)
				x = x +3
				#need to check for matches of length 4+
				while (x < Constants.GRID_SIZE && 
					candidate.kind == cells[y][x].kind && !cells[y][x].isLocked):
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
			var candidate = cells[y][x]
			var next_cell = cells[y+1][x]
			var third_cell = cells[y+2][x]
			if (!candidate.isLocked &&
				!next_cell.isLocked && next_cell.kind == candidate.kind && 
					!third_cell.isLocked && third_cell.kind == candidate.kind):
				#found a match!
				current_match.push_back(Vector2(x,y),)
				current_match.push_back(Vector2(x, y+1))
				current_match.push_back(Vector2(x, y+2))
				print("match found at %s" % y)
				y = y +3
				#need to check for matches of length 4+
				while y < Constants.GRID_SIZE && candidate.kind == cells[y][x].kind && !cells[y][x].isLocked:
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
				top_hat_pieces.push_back(Vector2(col, Constants.GRID_SIZE - 1))
				top_hat_pieces.push_back(Vector2(col, Constants.GRID_SIZE - 2))
				top_hat_pieces.push_back(Vector2(col, Constants.GRID_SIZE - 3))
			else:
				pass
				#todo: extend this logic to check for taller hats
				#todo: do we want to accept a 2-score hat?
	return top_hat_pieces

func _on_swap_selected():
	#destroy all matches
	#lock all complete top hats
	#lock all complete other hats
	#refill all columns at once, from bottom row up
	#repeat until no more matches and no more complete hats
	#if all hats are complete, game over
	
	await get_tree().process_frame #todo: probably replace this with waiting for an animation to finish
	var matches = get_matches()#this is a hack in place of a do while loop
	
	for m in matches:
		for cell_coords in m:
			cells[cell_coords.y][cell_coords.x].update_kind(null)
	
	#todo: probably more animation here
		
	var columns_with_new_hats = get_new_completed_hats()
	for h in columns_with_new_hats:
		var cell = cells[Constants.GRID_SIZE - 1][h]
		if cell.isTopHat:
			var all_top_hat_pieces = get_completed_top_hat(h)
			for piece in all_top_hat_pieces:
				cells[piece.y][piece.x].update_lock(true)
		else:
			cell.update_lock(true)
	
	
