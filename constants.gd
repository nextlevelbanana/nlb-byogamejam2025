extends Node

const KINDS = ["hatBottom", "hatMid", "hatTop", "cherry"]

const CELL_SIZE = 128	
const GRID_SIZE = 5

const GRID_ORIGIN = Vector2(300,300)
const RIGHTMOST_COLUMN_LEFT_X = (GRID_SIZE - 1) * CELL_SIZE + GRID_ORIGIN.x
const BOTTOM_ROW_TOP_Y = (GRID_SIZE - 1) * CELL_SIZE + GRID_ORIGIN.y
