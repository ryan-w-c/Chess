extends TileMap

onready var highlightTileMap = get_parent().get_node("highlight")
onready var moveTileMap = get_parent().get_node("move")
var whiteTurn : bool = true
var inCheck : bool = false
var checked : bool = false
var last
var cell
var selectedCell
var x_coord # x coordinate of selected cell for moves
var y_coord # y coordinate of selected cell for moves
var emptyCell # needed for initializing board and for deselecting selected cell
var cellID # the number associated with the cell that is identifies tile
var moveArray = [] # array filled with vectors that could be possible moves
var whiteKingCell = Vector2(5, 8)
var blackKingCell = Vector2(5, 1)
var checkList = []
var finalCheckList = []
var checkMoveDict = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO set up board
	emptyCell = world_to_map(get_global_mouse_position().snapped(Vector2(0, 0)))
	last = emptyCell
	selectedCell = emptyCell

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# add another boolean to only run once per turn
	if (!checked):
		checked = true
		if (whiteTurn):
			indirectDiagonalCheck(6, 13, 5, 1, whiteKingCell)
			indirectCrossCheck(6, 13, 5, 6, whiteKingCell)
			if (!checkMoveDict.empty() || inCheck):
				findMoves(6, 13)
				print(checkMoveDict)
				print(inCheck)
		else:
			indirectDiagonalCheck(0, 7, 11, 7, blackKingCell)
			indirectCrossCheck(0, 7, 11, 12, blackKingCell)
			if (!checkMoveDict.empty() || inCheck):
				findMoves(0, 7)
				print(checkMoveDict)
				print(inCheck)
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

func check(cell):
	# checks for checks and checkmate based on whos turn
	# highlights opponents pieces that make check
	# checks for players pieces that cannot be moved 
	# highlights players pieces that cannot be moved (on hover or always? -> if on hover we could use func protecting() above? and call it in select)
	
		# opponent directly cheching king
#		findMove()
	pass
	
func findMoves(start, end):
	var tiles = get_used_cells()
	var tempCell
	for i in tiles:
		tempCell = get_cell(i.x, i.y)
		if (tempCell > start && tempCell < end):
			x_coord = i.x
			y_coord = i.y
			match tempCell:
				1:
					#black bishop
					bishopMove(6, 13, true)
				7:
					#white bishop
					bishopMove(0, 7, true)
				2:
					#black king
					kingMove(6, 13, true)
				8:
					#white king
					kingMove(0, 7, true)
				3:
					#black knight
					knightMove(6, 13, true)
				9:
					#white knight
					knightMove(0, 7, true)
				4:
					# black pawn
					pawnMove(6, 13, 1, 2, true)
				10:
					# white pawn
					pawnMove(0, 7, -1, 7, true)
				5:
					#black queen
					queenMove(6, 13, true)
				11:
					#white queen
					queenMove(0, 7, true)
				6:
					#black rook
					rookMove(6, 13, true)
				12:
					#white rook
					rookMove(0, 7, true)
	
func evaluateMoves(knightKing = false):
	var tempKey = Vector2(x_coord, y_coord)
	var potentialMoves
	var realMoves = []
	var tempCell
	if (checkMoveDict.has(tempKey)):
		#indirectCheck
		potentialMoves = checkMoveDict[tempKey]
		for i in moveArray:
			tempCell = get_cellv(i)
			if (tempCell == -1):
				if i in potentialMoves:
					realMoves.append(i)
			else:
				if i in potentialMoves:
					realMoves.append(i)
				if (!knightKing):
					break
	else:
		#direct check
		for i in moveArray:
			tempCell = get_cellv(i)
			if (tempCell == -1):
				if i in finalCheckList:
					realMoves.append(i)
			else:
				if i in finalCheckList:
					realMoves.append(i)
				if (!knightKing):
					break
	if (!realMoves.empty()):
		checkMoveDict[Vector2(x_coord, y_coord)] = realMoves
	moveArray.clear()
	
func indirectDiagonalCheck(start, end, queen, bishop, kingCell):
	#upper left diagonal
	var temp_x = kingCell.x
	var temp_y = kingCell.y
	var peice_x
	var peice_y
	var count = 0
	var space = 0
	var temp
	while (temp_x > 0 && temp_y > 0):
		temp_x -= 1
		temp_y -= 1
		temp = get_cell(temp_x, temp_y)
		space += 1
		if (temp != queen && temp != bishop && temp != -1):
			#piece is not queen or bishop or clear
			if !(temp > start && temp < end):
				break
			count += 1
		elif (temp == queen || temp == bishop):
			if (count == 0):
				upperLeftCheck(temp_x, temp_y, space)
				inCheck = true
			else:
				# count == 1 -> one piece between king and opponent
				# piece cannot move off slope (only move upper left)
				checkList.append(Vector2(temp_x, temp_y))
				temp_x += 1
				temp_y += 1
				space -= 1
				temp = get_cell(temp_x, temp_y)
				while (temp == -1):
					checkList.append(Vector2(temp_x, temp_y))
					temp_x += 1
					temp_y += 1
					space -= 1
					temp = get_cell(temp_x, temp_y)
				peice_x = temp_x
				peice_y = temp_y
				while (space > 0):
					checkList.append(Vector2(temp_x, temp_y))
					temp_x += 1
					temp_y += 1
					space -= 1
				checkMoveDict[Vector2(peice_x, peice_y)] = checkList.duplicate()
				checkList.clear()
		if (count == 2):
			#two pieces protecting king we dont care about the rest
			break
			
	#upper right diagonal
	temp_x = kingCell.x
	temp_y = kingCell.y
	count = 0
	space = 0
	while (temp_x > 0 && temp_y > 0):
		temp_x += 1
		temp_y -= 1
		temp = get_cell(temp_x, temp_y)
		space += 1
		if (temp != queen && temp != bishop && temp != -1):
			#piece is not queen or bishop or clear
			if !(temp > start && temp < end):
				break
			count += 1
		elif (temp == queen || temp == bishop):
			if (count == 0):
				upperRightCheck(temp_x, temp_y, space)
				inCheck = true
			else:
				# count == 1 -> one piece between king and opponent
				# piece cannot move off slope (only move upper left)
				checkList.append(Vector2(temp_x, temp_y))
				temp_x -= 1
				temp_y += 1
				space -= 1
				temp = get_cell(temp_x, temp_y)
				while (temp == -1):
					checkList.append(Vector2(temp_x, temp_y))
					temp_x -= 1
					temp_y += 1
					space -= 1
					temp = get_cell(temp_x, temp_y)
				peice_x = temp_x
				peice_y = temp_y
				while (space > 0):
					checkList.append(Vector2(temp_x, temp_y))
					temp_x -= 1
					temp_y += 1
					space -= 1
				checkMoveDict[Vector2(peice_x, peice_y)] = checkList.duplicate()
				checkList.clear()
		if (count == 2):
			#two pieces protecting king we dont care about the rest
			break
			
	#lower left diagonal
	temp_x = kingCell.x
	temp_y = kingCell.y
	count = 0
	space = 0
	while (temp_x > 0 && temp_y > 0):
		temp_x -= 1
		temp_y += 1
		temp = get_cell(temp_x, temp_y)
		space += 1
		if (temp != queen && temp != bishop && temp != -1):
			#piece is not queen or bishop or clear
			if !(temp > start && temp < end):
				break
			count += 1
		elif (temp == queen || temp == bishop):
			if (count == 0):
				lowerLeftCheck(temp_x, temp_y, space)
				inCheck = true
			else:
				# count == 1 -> one piece between king and opponent
				# piece cannot move off slope (only move upper left)
				checkList.append(Vector2(temp_x, temp_y))
				temp_x += 1
				temp_y -= 1
				space -= 1
				temp = get_cell(temp_x, temp_y)
				while (temp == -1):
					checkList.append(Vector2(temp_x, temp_y))
					temp_x += 1
					temp_y -= 1
					space -= 1
					temp = get_cell(temp_x, temp_y)
				peice_x = temp_x
				peice_y = temp_y
				while (space > 0):
					checkList.append(Vector2(temp_x, temp_y))
					temp_x += 1
					temp_y -= 1
					space -= 1
				checkMoveDict[Vector2(peice_x, peice_y)] = checkList.duplicate()
				checkList.clear()
		if (count == 2):
			#two pieces protecting king we dont care about the rest
			break
			
	#lower right diagonal
	temp_x = kingCell.x
	temp_y = kingCell.y
	count = 0
	space = 0
	while (temp_x > 0 && temp_y > 0):
		temp_x += 1
		temp_y += 1
		temp = get_cell(temp_x, temp_y)
		space += 1
		if (temp != queen && temp != bishop && temp != -1):
			#piece is not queen or bishop or clear
			if !(temp > start && temp < end):
				break
			count += 1
		elif (temp == queen || temp == bishop):
			if (count == 0):
				lowerRightCheck(temp_x, temp_y, space)
				inCheck = true
			else:
				# count == 1 -> one piece between king and opponent
				# piece cannot move off slope (only move upper left)
				checkList.append(Vector2(temp_x, temp_y))
				temp_x -= 1
				temp_y -= 1
				space -= 1
				temp = get_cell(temp_x, temp_y)
				while (temp == -1):
					checkList.append(Vector2(temp_x, temp_y))
					temp_x -= 1
					temp_y -= 1
					space -= 1
					temp = get_cell(temp_x, temp_y)
				peice_x = temp_x
				peice_y = temp_y
				while (space > 0):
					checkList.append(Vector2(temp_x, temp_y))
					temp_x -= 1
					temp_y -= 1
					space -= 1
				checkMoveDict[Vector2(peice_x, peice_y)] = checkList.duplicate()
				checkList.clear()
		if (count == 2):
			#two pieces protecting king we dont care about the rest
			break

func indirectCrossCheck(start, end, queen, rook, kingCell):
	#up
	var temp_coord = kingCell.y
	var peice_coord
	var count = 0
	var space = 0
	var temp
	while (temp_coord > 0):
		temp_coord -= 1
		temp = get_cell(kingCell.x, temp_coord)
		space += 1
		if (temp != queen && temp != rook && temp != -1):
			#piece is not queen or rook or clear
			if !(temp > start && temp < end):
				break
			count += 1
		elif (temp == queen || temp == rook):
			if (count == 0):
				upCheck(temp_coord, kingCell.x, space)
				inCheck = true
			else:
				# count == 1 -> one piece between king and opponent
				# piece cannot move off slope (only move upper left)
				checkList.append(Vector2(kingCell.x, temp_coord))
				temp_coord += 1
				space -= 1
				temp = get_cell(kingCell.x, temp_coord)
				while (temp == -1):
					checkList.append(Vector2(kingCell.x, temp_coord))
					temp_coord += 1
					space -= 1
					temp = get_cell(kingCell.x, temp_coord)
				peice_coord = temp_coord
				while (space > 0):
					checkList.append(Vector2(kingCell.x, temp_coord))
					temp_coord += 1
					space -= 1
				checkMoveDict[Vector2(kingCell.x, peice_coord)] = checkList.duplicate()
				checkList.clear()
		if (count == 2):
			#two pieces protecting king we dont care about the rest
			break
			
	#down
	temp_coord = kingCell.y
	count = 0
	space = 0
	while (temp_coord > 0):
		temp_coord += 1
		temp = get_cell(kingCell.x, temp_coord)
		space += 1
		if (temp != queen && temp != rook && temp != -1):
			#piece is not queen or rook or clear
			if !(temp > start && temp < end):
				break
			count += 1
		elif (temp == queen || temp == rook):
			if (count == 0):
				downCheck(temp_coord, kingCell.x, space)
				inCheck = true
			else:
				# count == 1 -> one piece between king and opponent
				# piece cannot move off slope (only move upper left)
				checkList.append(Vector2(kingCell.x, temp_coord))
				temp_coord -= 1
				space -= 1
				temp = get_cell(kingCell.x, temp_coord)
				while (temp == -1):
					checkList.append(Vector2(kingCell.x, temp_coord))
					temp_coord -= 1
					space -= 1
					temp = get_cell(kingCell.x, temp_coord)
				peice_coord = temp_coord
				while (space > 0):
					checkList.append(Vector2(kingCell.x, temp_coord))
					temp_coord -= 1
					space -= 1
				checkMoveDict[Vector2(kingCell.x, peice_coord)] = checkList.duplicate()
				checkList.clear()
		if (count == 2):
			#two pieces protecting king we dont care about the rest
			break
			
	#right
	temp_coord = kingCell.x
	count = 0
	space = 0
	while (temp_coord > 0):
		temp_coord += 1
		temp = get_cell(temp_coord, kingCell.y)
		space += 1
		if (temp != queen && temp != rook && temp != -1):
			#piece is not queen or rook or clear
			if !(temp > start && temp < end):
				break
			count += 1
		elif (temp == queen || temp == rook):
			if (count == 0):
				rightCheck(temp_coord, kingCell.y, space)
				inCheck = true
			else:
				# count == 1 -> one piece between king and opponent
				# piece cannot move off slope (only move upper left)
				checkList.append(Vector2(temp_coord, kingCell.y))
				temp_coord -= 1
				space -= 1
				temp = get_cell(temp_coord, kingCell.y)
				while (temp == -1):
					checkList.append(Vector2(temp_coord, kingCell.y))
					temp_coord -= 1
					space -= 1
					temp = get_cell(temp_coord, kingCell.y)
				peice_coord = temp_coord
				while (space > 0):
					checkList.append(Vector2(temp_coord, kingCell.y))
					temp_coord -= 1
					space -= 1
				checkMoveDict[Vector2(peice_coord, kingCell.y)] = checkList.duplicate()
				checkList.clear()
		if (count == 2):
			#two pieces protecting king we dont care about the rest
			break
	
	#left
	temp_coord = kingCell.x
	count = 0
	space = 0
	while (temp_coord > 0):
		temp_coord -= 1
		temp = get_cell(temp_coord, kingCell.y)
		space += 1
		if (temp != queen && temp != rook && temp != -1):
			#piece is not queen or rook or clear
			if !(temp > start && temp < end):
				break
			count += 1
		elif (temp == queen || temp == rook):
			if (count == 0):
				leftCheck(temp_coord, kingCell.y, space)
				inCheck = true
			else:
				# count == 1 -> one piece between king and opponent
				# piece cannot move off slope (only move upper left)
				checkList.append(Vector2(temp_coord, kingCell.y))
				temp_coord += 1
				space -= 1
				temp = get_cell(temp_coord, kingCell.y)
				while (temp == -1):
					checkList.append(Vector2(temp_coord, kingCell.y))
					temp_coord += 1
					space -= 1
					temp = get_cell(temp_coord, kingCell.y)
				peice_coord = temp_coord
				while (space > 0):
					checkList.append(Vector2(temp_coord, kingCell.y))
					temp_coord += 1
					space -= 1
				checkMoveDict[Vector2(peice_coord, kingCell.y)] = checkList.duplicate()
				checkList.clear()
		if (count == 2):
			#two pieces protecting king we dont care about the rest
			break

func upperLeftCheck(temp_x, temp_y, space):
	while (space > 0):
		finalCheckList.append(Vector2(temp_x, temp_y))
		temp_x += 1
		temp_y += 1
		space -= 1

func upperRightCheck(temp_x, temp_y, space):
	while (space > 0):
		finalCheckList.append(Vector2(temp_x, temp_y))
		temp_x -= 1
		temp_y += 1
		space -= 1

func lowerLeftCheck(temp_x, temp_y, space):
	while (space > 0):
		finalCheckList.append(Vector2(temp_x, temp_y))
		temp_x += 1
		temp_y -= 1
		space -= 1

func lowerRightCheck(temp_x, temp_y, space):
	while (space > 0):
		finalCheckList.append(Vector2(temp_x, temp_y))
		temp_x -= 1
		temp_y -= 1
		space -= 1

func upCheck(temp_coord, king_coord, space):
	while (space > 0):
		finalCheckList.append(Vector2(king_coord, temp_coord))
		temp_coord += 1
		space -= 1

func downCheck(temp_coord, king_coord, space):
	while (space > 0):
		finalCheckList.append(Vector2(king_coord, temp_coord))
		temp_coord -= 1
		space -= 1

func rightCheck(temp_coord, king_coord, space):
	while (space > 0):
		finalCheckList.append(Vector2(temp_coord, king_coord))
		temp_coord -= 1
		space -= 1

func leftCheck(temp_coord, king_coord, space):
	while (space > 0):
		finalCheckList.append(Vector2(temp_coord, king_coord))
		temp_coord += 1
		space -= 1

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

func pawnMove(start, end, pawnDir, row, check = false):
	# pawn is selected display cells where they can move
	# TODO en passant special move
	var tempCell
	# pawns in start position
	if (check):
		if (y_coord == row):
			if (get_cell(x_coord, y_coord + pawnDir) == -1):
				moveArray.append(Vector2(x_coord, y_coord + pawnDir))
				if (get_cell(x_coord, y_coord + pawnDir + pawnDir) == -1):
					moveArray.append(Vector2(x_coord, y_coord + pawnDir + pawnDir))
		# move forward one
		elif (get_cell(x_coord, y_coord + pawnDir) == -1):
			moveArray.append(Vector2(x_coord, y_coord + pawnDir))
		# pawn attacks
		tempCell = get_cell(x_coord - 1, y_coord + pawnDir)
		if (tempCell > start && tempCell < end):
			moveArray.append(Vector2(x_coord - 1, y_coord + pawnDir))
		tempCell = get_cell(x_coord + 1, y_coord + pawnDir)
		if (tempCell > start && tempCell < end):
			moveArray.append(Vector2(x_coord + 1, y_coord + pawnDir))
		evaluateMoves()
	else:
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

func knightMove(start, end, check = false):
	#knight is selected display cells where they can move
	moveArray.append(Vector2(x_coord - 1, y_coord + 2))
	moveArray.append(Vector2(x_coord + 1, y_coord + 2))
	moveArray.append(Vector2(x_coord - 1, y_coord - 2))
	moveArray.append(Vector2(x_coord + 1, y_coord - 2))
	moveArray.append(Vector2(x_coord + 2, y_coord + 1))
	moveArray.append(Vector2(x_coord + 2, y_coord - 1))
	moveArray.append(Vector2(x_coord - 2, y_coord + 1))
	moveArray.append(Vector2(x_coord - 2, y_coord - 1))
	if (!check):
		showMoves(start, end, true)
	else:
		evaluateMoves(true)
	
func rookMove(start, end, check = false):
	#rook is selected display cells where they can move
	cross(start, end, check)
	
func bishopMove(start, end, check = false):
	#bishop is selected display cells where they can move
	diagonal(start, end, check)
	
func kingMove(start, end, check = false):
	#king is selected display cells where they can move
	# TODO not when king will put himself in check
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
	if (!check):
		showMoves(start, end, true)
	else:
		evaluateMoves(true)
	
func queenMove(start, end, check = false):
	#queen is selected display cells where they can move
	diagonal(start, end, check)
	cross(start, end, check)
	
func diagonal(start, end, check = false):
	#upper left diagonal
	var temp_x = x_coord
	var temp_y = y_coord
	while (temp_x > 0 && temp_y > 0):
		temp_x -= 1
		temp_y -= 1
		moveArray.append(Vector2(temp_x, temp_y))
	if (!check):
		showMoves(start, end)
	else:
		evaluateMoves()
	
	# upper right diagonal
	temp_x = x_coord
	temp_y = y_coord
	while (temp_x < 9 && temp_y > 0):
		temp_x += 1
		temp_y -= 1
		moveArray.append(Vector2(temp_x, temp_y))
	if (!check):
		showMoves(start, end)
	else:
		evaluateMoves()
	
	# lower left diagonal
	temp_x = x_coord
	temp_y = y_coord
	while (temp_x > 0 && temp_y < 9):
		temp_x -= 1
		temp_y += 1
		moveArray.append(Vector2(temp_x, temp_y))
	if (!check):
		showMoves(start, end)
	else:
		evaluateMoves()
		
	# lower right diagonal
	temp_x = x_coord
	temp_y = y_coord
	while (temp_x < 9 && temp_y < 9):
		temp_x += 1
		temp_y += 1
		moveArray.append(Vector2(temp_x, temp_y))
	if (!check):
		showMoves(start, end)
	else:
		evaluateMoves()
		
func cross(start, end, check = false):
	#up
	var temp = y_coord
	while (temp > 0):
		temp -= 1
		moveArray.append(Vector2(x_coord, temp))
	if (!check):
		showMoves(start, end)
	else:
		evaluateMoves()
		
#	#down
	temp = y_coord
	while (temp < 9):
		temp += 1
		moveArray.append(Vector2(x_coord, temp))
	if (!check):
		showMoves(start, end)
	else:
		evaluateMoves()
	
#	#left
	temp = x_coord
	while (temp > 0):
		temp -= 1
		moveArray.append(Vector2(temp, y_coord))
	if (!check):
		showMoves(start, end)
	else:
		evaluateMoves()
		
#	#right
	temp = x_coord
	while (temp < 9):
		temp += 1
		moveArray.append(Vector2(temp, y_coord))
	if (!check):
		showMoves(start, end)
	else:
		evaluateMoves()
		
func makeMove():
	# on mouse release if clicked on possible move 
	# set previous cell to empty and new cell to cellID
	#clear highlight tilemap
	var temp = get_cellv(selectedCell)
	if (moveTileMap.get_cellv(cell) > 0):
		if (temp == 2):
			#black king
			blackKingCell = cell
		elif (temp == 8):
			# white King
			whiteKingCell = cell
		set_cellv(cell, temp)
		set_cellv(selectedCell, -1)
		highlightTileMap.set_cellv(selectedCell, -1)
		selectedCell = emptyCell
		moveTileMap.clear()
		if (whiteTurn):
			whiteTurn = false
		else:
			whiteTurn = true
		inCheck = false
		checked = false
		checkList.clear()
		checkMoveDict.clear()

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
			if (inCheck):
				if (cell in checkMoveDict):
					# only display possible moves for cells in checkMoveDict
					var tempCell
					for i in checkMoveDict[cell]:
						if (i in finalCheckList):
							tempCell = get_cellv(i)
							if (tempCell == -1):
								# move is putting piece between king and opponent
								moveTileMap.set_cellv(i, 2)
							else:
								# move is killing opponents piece
								moveTileMap.set_cellv(i, 1)
			else:
				if (cell in checkMoveDict):
					# only display possible moves for cells in checkMoveDict
					var tempCell
					for i in checkMoveDict[cell]:
						if (i in finalCheckList):
							tempCell = get_cellv(i)
							if (tempCell == -1):
								# move is putting piece between king and opponent
								moveTileMap.set_cellv(i, 2)
							else:
								# move is killing opponents piece
								moveTileMap.set_cellv(i, 1)
				else:
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
