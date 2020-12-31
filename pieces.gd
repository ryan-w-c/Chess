extends TileMap

onready var highlightTileMap = get_parent().get_node("highlight")
onready var moveTileMap = get_parent().get_node("move")
var whiteTurn : bool = true
var last
var cell
var selectedCell
var x_coord # x coordinate of selected cell for moves
var y_coord # y coordinate of selected cell for moves
var emptyCell # needed for initializing board and for deselecting selected cell
var cellID # the number associated with the cell that is identifies tile
var moveArray = [] # array filled with vectors that could be possible moves

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO set up board
	emptyCell = world_to_map(get_global_mouse_position().snapped(Vector2(0, 0)))
	last = emptyCell
	selectedCell = emptyCell

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check()
	# TODO if piece is highlighted from check make it non hoverable and non selectable
	hover()
	if (Input.is_action_just_released("on_left_click")):
		if (whiteTurn):
			select(6, 13)
		else:
			select(0, 7)
		
func protecting():
	# returns true if cell cannot be moved because protecting king
	# else returns false
	pass

func check():
	# checks for checks and checkmate based on whos turn
	# highlights opponents pieces that make check
	# checks for players pieces that cannot be moved 
	# highlights players pieces that cannot be moved (on hover or always? -> if on hover we could use func protecting() above)
	pass

func showMoves():
	var tempCell
	# TODO add check to make sure other piece is not in way
	#  maybe we call showMoves multiple times from with [piece]Move() and make sure when we append we append in order from distance from piece away
	# and we call the function for each direction depending on the piece
	# IMPORTANT: does not work for pawns, and i think not knights or kings 
	if (whiteTurn):
		for i in moveArray:
			tempCell = get_cellv(i)
			if (tempCell == -1):
				moveTileMap.set_cellv(i, 2)
			elif (tempCell > 0 && tempCell < 7):
				moveTileMap.set_cellv(i, 1)
			else:
				break
	else:
		for i in moveArray:
			tempCell = get_cellv(i)
			if (tempCell == -1):
				moveTileMap.set_cellv(i, 2)
			elif (tempCell > 6 && tempCell < 13):
				moveTileMap.set_cellv(i, 1)
			else:
				break
	moveArray.clear()

func pawnMove(start, end, pawnDir, row):
	# pawn is selected display cells where they can move
	# TODO en passant special move
	var tempCell
	if (y_coord == row):
		if (get_cell(x_coord, y_coord + pawnDir) == -1):
			moveTileMap.set_cell(x_coord, y_coord + pawnDir, 2)
			if (get_cell(x_coord, y_coord + pawnDir + pawnDir) == -1):
				moveTileMap.set_cell(x_coord, y_coord + pawnDir + pawnDir, 2)
	elif (get_cell(x_coord, y_coord + pawnDir) == -1):
		moveTileMap.set_cell(x_coord, y_coord + pawnDir, 2)
	tempCell = get_cell(x_coord - 1, y_coord + pawnDir)
	if (tempCell > start && tempCell < end):
		moveTileMap.set_cell(x_coord - 1, y_coord + pawnDir, 1)
	tempCell = get_cell(x_coord + 1, y_coord + pawnDir)
	if (tempCell > start && tempCell < end):
		moveTileMap.set_cell(x_coord + 1, y_coord + pawnDir, 1)
	
func pawnPromotion():
	#pawn made it to the other end can turn into queen, bishop, rook, or knight
	pass

func knightMove():
	#knight is selected display cells where they can move
	pass
	
func rookMove():
	#rook is selected display cells where they can move
	pass
	
func bishopMove():
	#bishop is selected display cells where they can move
	pass
	
func kingMove():
	#king is selected display cells where they can move
	#remember weird move with rook (castling)
	pass
	
func queenMove():
	#queen is selected display cells where they can move
	pass
	
func diagonal():
	#upper left diagonal
	showMoves()
	# upper right diagonal
	showMoves()
	# lower left diagonal
	showMoves()
	# lower right diagonal
	showMoves()


func cross():
	#up
	showMoves()
	#down
	showMoves()
	#left
	showMoves()
	#right
	showMoves()
	
func makeMove():
	# on mouse release if clicked on possible move 
	# set previous cell to empty and new cell to cellID
	#clear highlight tilemap
	pass

func hover():
	# we could probably rework it so selected highlight is on move instead i think it would be easier code to follow
	# and we could rename highlight to hover
	cell = world_to_map(get_global_mouse_position().snapped(Vector2(0, 0)))
	cellID = get_cellv(cell)
	if (cell != last && last != selectedCell && cell != selectedCell):
		if (cellID != 13):
			highlightTileMap.set_cellv(cell, 0)
		highlightTileMap.set_cellv(last, -1)
	if (cell == selectedCell && last != selectedCell):
		highlightTileMap.set_cellv(last, -1)
	if (last == selectedCell && cell != selectedCell):
		if (cellID != 13):
			highlightTileMap.set_cellv(cell, 0)
	last = cell

func select(start, end):
	if (cellID > start && cellID < end):
		moveTileMap.clear()
		if (cell != selectedCell):
			highlightTileMap.set_cellv(selectedCell, -1)
			selectedCell = cell
			x_coord = selectedCell.x
			y_coord = selectedCell.y
			highlightTileMap.set_cellv(cell, 5)
			match cellID:
				1, 7:
					# bishop
					bishopMove()
				2, 8:
					# king
					kingMove()
				3, 9:
					# knight
					knightMove()
				4:
					# black pawn
					pawnMove(start + 6, end + 6, 1, 2)
				10:
					# white pawn
					pawnMove(13 - end, 13 - start, -1, 7)
				5, 11:
					# queen
					queenMove()
				6, 12:
					# rook
					rookMove()
		else:
			highlightTileMap.set_cellv(selectedCell, 0)
			selectedCell = emptyCell
