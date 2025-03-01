extends Node

const KINDS = ["hatBottom", "hatMid", "hatTop", "ball", "bone", "bowl", "chef", "cowboy", "party"]
const ALL_HATS = ["hatTop", "hatMid", "hatBottom", "chef", "cowboy", "party"]
const NON_HATS = ["ball", "bone", "bowl"]

const CELL_SIZE = 150	
const GRID_SIZE = 5

const GRID_ORIGIN = Vector2(585,209)
const RIGHTMOST_COLUMN_LEFT_X = (GRID_SIZE - 1) * CELL_SIZE + GRID_ORIGIN.x
const BOTTOM_ROW_TOP_Y = (GRID_SIZE - 1) * CELL_SIZE + GRID_ORIGIN.y
