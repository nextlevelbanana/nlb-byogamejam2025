extends Node2D

var cells = []
var preview_cells = []
var Cell = preload("res://cell.tscn")

var firstSelected
var secondSelected

var hats_complete = 0

var is_input_locked = false

var PoofScene = preload("res://poof.tscn")

func _ready() -> void:
	$Cursor.position = Constants.GRID_ORIGIN
	initialize_grid()
	SignalBus.connect("swap_selected", _on_swap_selected)

func _process(delta: float) -> void:
	check_for_game_over()
	
func _unhandled_key_input(event: InputEvent) -> void:
	if is_input_locked: 
		return
		
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
		var newCell = Cell.instantiate()
		newCell.set_pos(-1, column)
		newCell.update_kind(preview)
		preview_cells.append(newCell)
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
	var cur = cells[cell_pos.y][cell_pos.x]
	if cur.isLocked:
		return #todo: animation, sound etc to indicate you can't select a locked hat
	
	if !firstSelected:
		firstSelected = cur
		$FirstSelection.position = $Cursor.position
		$FirstSelection.visible = true
		#todo: an else 
	else:
		#selecting the same cell twice un-selects it
		if (firstSelected.grid_pos.y == cell_pos.y && firstSelected.grid_pos.x == cell_pos.x):
			reset_cursors()
		elif cell_pos.distance_to(firstSelected.grid_pos) > 1:
			#todo: play WRONG buzzer, shake, etc
			print("too far away")
			#pass
		else:
			secondSelected = cur
			$SecondSelection.position = $Cursor.position
			$SecondSelection.visible = true
			print("swapping!")
			swap()

#this is working
func getCell(cursor_pos):
	return Vector2((cursor_pos.x - Constants.GRID_ORIGIN.x) / Constants.CELL_SIZE, (cursor_pos.y - Constants.GRID_ORIGIN.y) / Constants.CELL_SIZE)
	
#this is working
func swap():
	toggle_input_lock(true)

	var tmp = firstSelected.kind
	var tmp2 = secondSelected.kind
	
	var pos1 = firstSelected.position
	var pos2 = secondSelected.position
		
	await animate_swap(pos1, pos2)

	cells[firstSelected.grid_pos.y][firstSelected.grid_pos.x].position = pos1
	cells[secondSelected.grid_pos.y][secondSelected.grid_pos.x].position = pos2
	# I switched which cell gets to be tmp versus tmp2, but now it doesn't seem to be matching
	cells[firstSelected.grid_pos.y][firstSelected.grid_pos.x].update_kind(tmp2)
	cells[secondSelected.grid_pos.y][secondSelected.grid_pos.x].update_kind(tmp)
	
	reset_cursors()
	SignalBus.swap_selected.emit()

func animate_swap(pos1, pos2):
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(secondSelected, "position", pos1, 0.5)
	tween.tween_property(firstSelected, "position", pos2, 0.5)
	await tween.finished
	

	
#this is working
func reset_cursors():
	firstSelected = null
	secondSelected = null
	$FirstSelection.visible = false
	$SecondSelection.visible = false
	

#this is working
func refill_preview_cells():
	for preview in preview_cells:
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
				y = y + 1

	return matches
				

# returns the column indexes that have new completed hats
#I feel good about this one
func get_new_completed_hats():
	var hat_matches = []
	for column in Constants.GRID_SIZE:
		var current_cell = cells[Constants.GRID_SIZE - 1][column]
		if !current_cell.isLocked && current_cell.isHat:
			if current_cell.isTopHat:
				if get_completed_top_hat(column).size():
					print("hat found at %s" % column)
					hat_matches.push_back(column)
			else:
				print("hat found at %s" % column)
				hat_matches.push_back(column)
		
	return hat_matches

# assumes column is unlocked
# returns the coords of all top hat pieces, or an empty array if hat incomplete, in a given column
func get_completed_top_hat(col):
	var top_hat_pieces = []
	if cells[Constants.GRID_SIZE - 1][col].kind == "hatBottom" && cells[Constants.GRID_SIZE - 2][col].kind == "hatMid":
		var shouldContinue = true
		var row = Constants.GRID_SIZE - 3
		while shouldContinue && row > -1:
			if cells[row][col].kind == "hatMid":
				row = row - 1
			elif cells[row][col].kind == "hatTop":
				#we've completed the hat!
				for n in range(Constants.GRID_SIZE - 1, row - 1, -1):
					top_hat_pieces.push_back(Vector2(col, n))
				shouldContinue = false
			else:
				#there's not a hat here
				shouldContinue = false
	return top_hat_pieces
	
func toggle_input_lock(newState):
	if newState:
		is_input_locked = true
		$Cursor.visible = false
	else:
		is_input_locked = false
		$Cursor.visible = true

func _on_swap_selected():	
	await get_tree().process_frame #todo: probably replace this with waiting for an animation to finish
	# not confident the matches are getting found correctly, think I'm seeing false positives
	
	var should_check_again = false
	
	var columns_with_new_hats = get_new_completed_hats()
	if columns_with_new_hats.size():
		print("new hat found")
		lock_hats_in_columns(columns_with_new_hats)
	
	await get_tree().process_frame
	
	var matches = get_matches()#this is a hack in place of a do while loop
	
	#await get_tree().process_frame #todo: probably replace this with waiting for an animation to finish
	if matches.size():
		should_check_again = true
		for m in matches:
			for cell_coords in m:
				await poof (cells[cell_coords.y][cell_coords.x].position)
				cells[cell_coords.y][cell_coords.x].update_kind(null)
		refill_empty_cells()
		
	while should_check_again:
		print("checking again")
		await get_tree().process_frame
		columns_with_new_hats = get_new_completed_hats()
		print("columns with new hats?", columns_with_new_hats.size())
		if columns_with_new_hats.size():
			lock_hats_in_columns(columns_with_new_hats)
			
		matches = get_matches()
		print("matches found: %s" % matches.size())
		if !matches.size():
			should_check_again = false
		else:
			should_check_again = true
			for m in matches:
				for cell_coords in m:
					cells[cell_coords.y][cell_coords.x].update_kind(null)
			refill_empty_cells()
	
	toggle_input_lock(false)

func lock_hats_in_columns(col):
	for h in col:
		var cell = cells[Constants.GRID_SIZE - 1][h]
		if cell.isTopHat:
			var all_top_hat_pieces = get_completed_top_hat(h)
			for piece in all_top_hat_pieces:
				cells[piece.y][piece.x].update_lock(true)
			SignalBus.top_hat_made.emit()
		else:
			SignalBus.bad_hat_made.emit()
			cell.update_lock(true)

func find_lowest_empty(column):
	for i in range(Constants.GRID_SIZE -1, -1, -1):
		if !cells[i][column].kind:
			return i
	#nothing empty in column
	return -1

func find_next_lowest_not_empty(empty, column):
	for i in range(empty - 1, -1, -1):
		if cells[i][column].kind != null:
			return i
	return -1


func drop_prev(row, column):
	var tween = get_tree().create_tween().set_parallel(true)
	var original_pos = preview_cells[column].position
	tween.tween_property(preview_cells[column], "position", Vector2(original_pos.x, original_pos.y + Constants.CELL_SIZE), .5)
	await tween.finished
	return original_pos
	
func drop_in_grid(row, column):
	var tween = get_tree().create_tween().set_parallel(true)
	var original_pos = cells[row][column].position
	tween.tween_property(cells[row][column], "position", Vector2(original_pos.x, original_pos.y + Constants.CELL_SIZE), .5)
	await tween.finished
	return original_pos

func poof (pos): 
	print(pos)
	var new_poof = PoofScene.instantiate()
	new_poof.position = pos
	add_child(new_poof)

func refill_empty_cells():
	print("refilling empty cells")
	for column in Constants.GRID_SIZE:
		var cur = find_lowest_empty(column)
		while cur != -1:
			var fill = find_next_lowest_not_empty(cur, column)
			if fill == -1:
				var original_pos = await drop_prev(cur, column)
				cells[cur][column].update_kind(preview_cells[column].kind)
				preview_cells[column].position = original_pos
				preview_cells[column].update_kind(Constants.KINDS.pick_random())
			else:
				#var original_pos = await drop_in_grid(fill, column)
				cells[cur][column].update_kind(cells[fill][column].kind)
				#cells[fill][column].position = original_pos
				cells[fill][column].update_kind(null)
				await get_tree().process_frame
			cur = cur - 1
	
# this isn't hooked up to anything yet				
func check_for_game_over():
	var is_over = true
	for col in Constants.GRID_SIZE:
		if !cells[Constants.GRID_SIZE - 1][col].isLocked:
			is_over = false
	
	if is_over:
		SignalBus.game_over.emit()
		
	
