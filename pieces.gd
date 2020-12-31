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
	# highlights players pieces that cannot be moved (on hover or always? -> if on hover we could use func protecting() above? and call it in select)
	pass

func showMoves(start, end, knightKing = false):
	var tempCell
	# TODO should not show moves that king cannot make
	# IMPORTANT: does not work for pawns 
	for i in moveArray:
		tempCell = get_cellv(i)
		if (tempCell == -1):
			moveTileMap.set_cellv(i, 2)
		elif (tempCell > start && tempCell < end):
			moveTileMap.set_cellv(i, 1)
			if (!knightKing):
				break
		else:
			if (!knightKing):
				break
	moveArray.clear()

func pawnMove(start, end, pawnDir, row):
	# pawn is selected display cells where they can move
	# TODO en passant special move
	var tempCell
	# pawns in start position
	if (y_coord == row):
		if (get_cell(x_coord, y_coord + pawnDir) == -1):
			moveTileMap.set_cell(x_coord, y_coord + pawnDir, 2)
			if (get_cell(x_coord, y_coord + pawnDir + pawnDir) == -1):
				moveTileMap.set_cell(x_coord, y_coord + pawnDir + pawnDir, 2)
	# move forward one
	elif (get_cell(x_coord, y_coord + pawnDir) == -1):
		moveTileMap.set_cell(x_coord, y_coord + pawnDir, 2)
	# pawn attacks
	tempCell = get_cell(x_coord - 1, y_coord + pawnDir)
	if (tempCell > start && tempCell < end):
		moveTileMap.set_cell(x_coord - 1, y_coord + pawnDir, 1)
	tempCell = get_cell(x_coord + 1, y_coord + pawnDir)
	if (tempCell > start && tempCell < end):
		moveTileMap.set_cell(x_coord + 1, y_coord + pawnDir, 1)
	
func pawnPromotion():
	#pawn made it to the other end can turn into queen, bishop, rook, or knight
	pass

func knightMove(start, end):
	#knight is selected display cells where they can move
	moveArray.append(Vector2(x_coord - 1, y_coord + 2))
	moveArray.append(Vector2(x_coord + 1, y_coord + 2))
	moveArray.append(Vector2(x_coord - 1, y_coord - 2))
	moveArray.append(Vector2(x_coord + 1, y_coord - 2))
	moveArray.append(Vector2(x_coord + 2, y_coord + 1))
	moveArray.append(Vector2(x_coord + 2, y_coord - 1))
	moveArray.append(Vector2(x_coord - 2, y_coord + 1))
	moveArray.append(Vector2(x_coord - 2, y_coord - 1))
	showMoves(start, end, true)
	
func rookMove(start, end):
	#rook is selected display cells where they can move
	cross(start, end)
	
func bishopMove(start, end):
	#bishop is selected display cells where they can move
	diagonal(start, end)
	
func kingMove(start, end):
	#king is selected display cells where they can move
	#remember weird move with rook (castling)
	#up/down
	moveArray.append(Vector2(x_coord, y_coord + 1))
	moveArray.append(Vector2(x_coord, y_coord - 1))
	#left/right
	moveArray.append(Vector2(x_coord + 1, y_coord))
	moveArray.append(Vector2(x_coord- 1, y_coord))
	# diagonals
	moveArray.append(Vector2(x_coord + 1, y_coord - 1))
	moveArray.append(Vector2(x_coord- 1, y_coord - 1))
	moveArray.append(Vector2(x_coord + 1, y_coord + 1))
	moveArray.append(Vector2(x_coord- 1, y_coord + 1))
	showMoves(start, end, true)
	
func queenMove(start, end):
	#queen is selected display cells where they can move
	diagonal(start, end)
	cross(start, end)
	
func diagonal(start, end):
	#upper left diagonal
	var temp_x = x_coord
	var temp_y = y_coord
	while (temp_x > 0 && temp_y > 0):
		temp_x -= 1
		temp_y -= 1
		moveArray.append(Vector2(temp_x, temp_y))
	showMoves(start, end)
	
	# upper right diagonal
	temp_x = x_coord
	temp_y = y_coord
	while (temp_x < 9 && temp_y > 0):
		temp_x += 1
		temp_y -= 1
		moveArray.append(Vector2(temp_x, temp_y))
	showMoves(start, end)
	
	# lower left diagonal
	temp_x = x_coord
	temp_y = y_coord
	while (temp_x > 0 && temp_y < 9):
		temp_x -= 1
		temp_y += 1
		moveArray.append(Vector2(temp_x, temp_y))
	showMoves(start, end)
	
	# lower right diagonal
	temp_x = x_coord
	temp_y = y_coord
	while (temp_x < 9 && temp_y < 9):
		temp_x += 1
		temp_y += 1
		moveArray.append(Vector2(temp_x, temp_y))
	showMoves(start, end)

func cross(start, end):
	#up
	var temp = y_coord
	while (temp > 0):
		temp -= 1
		moveArray.append(Vector2(x_coord, temp))
	showMoves(start, end)
	
#	#down
	temp = y_coord
	while (temp < 9):
		temp += 1
		moveArray.append(Vector2(x_coord, temp))
	showMoves(start, end)
	
#	#left
	temp = x_coord
	while (temp > 0):
		temp -= 1
		moveArray.append(Vector2(temp, y_coord))
	showMoves(start, end)
	
#	#right
	temp = x_coord
	while (temp < 9):
		temp += 1
		moveArray.append(Vector2(temp, y_coord))
	showMoves(start, end)
	
func makeMove():
	# on mouse release if clicked on possible move 
	# set previous cell to empty and new cell to cellID
	#clear highlight tilemap
	if (moveTileMap.get_cellv(cell) > 0):
		set_cellv(cell, get_cellv(selectedCell))
		set_cellv(selectedCell, -1)
		highlightTileMap.set_cellv(selectedCell, -1)
		selectedCell = emptyCell
		moveTileMap.clear()
		if (whiteTurn):
			whiteTurn = false
		else:
			whiteTurn = true




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
				1:
					#black bishop
					bishopMove(6, 13)
				7:
					#white bishop
					bishopMove(0, 7)
				2:
					#black king
					kingMove(6, 13)
				8:
					#white king
					kingMove(0, 7)
				3:
					#black knight
					knightMove(6, 13)
				9:
					#white knight
					knightMove(0, 7)
				4:
					# black pawn
					pawnMove(6, 13, 1, 2)
				10:
					# white pawn
					pawnMove(0, 7, -1, 7)
				5:
					#black queen
					queenMove(6, 13)
				11:
					#white queen
					queenMove(0, 7)
				6:
					#black rook
					rookMove(6, 13)
				12:
					#white rook
					rookMove(0, 7)
		else:
			highlightTileMap.set_cellv(selectedCell, 0)
			selectedCell = emptyCell
	else:
		makeMove()
