extends TileMap

onready var highlightTileMap = get_parent().get_node("highlight")
onready var moveTileMap = get_parent().get_node("move")
onready var blackGear = get_parent().get_node("blackOptionBtn")
onready var whiteGear = get_parent().get_node("whiteOptionBtn")
var whiteTurn : bool = true
var inCheck : bool = false
var checked : bool = false #if we have checked for a check
var pawnBool : bool = false
var disableSelect : bool = true
var whiteKingMoved : bool = false
var whiteKingRookMoved : bool = false
var whiteQueenRookMoved : bool = false
var blackKingMoved : bool = false
var blackKingRookMoved : bool = false
var blackQueenRookMoved : bool = false
var checkCount = 0
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
var indirectCheckMoveDict = {}
var pawn_coord # used for pawn promotion and en passant
var pawnCount = 0 #needed for en passant

# Called when the node enters the scene tree for the first time.
func _ready():
	emptyCell = world_to_map(get_global_mouse_position().snapped(Vector2(0, 0)))
	last = emptyCell
	selectedCell = emptyCell
	for button in get_tree().get_nodes_in_group("pp"):
		button.connect("pressed", self, "_pp_pressed", [button])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (!checked):
		checked = true
		if (whiteTurn):
			kingMove(6, 13, whiteKingCell, 3, 4, -1, 5, 1, 6)
			pawnKnightCheck(whiteKingCell, 3, 4, -1)
			indirectDiagonalCheck(6, 13, 5, 1, whiteKingCell)
			indirectCrossCheck(6, 13, 5, 6, whiteKingCell)
			if !inCheck:
				castle(6, 13, whiteKingCell, 3, 4, -1, 5, 1, 6, whiteKingMoved, whiteKingRookMoved, whiteQueenRookMoved)
			if (!indirectCheckMoveDict.empty() || inCheck):
				findMoves(6, 13)
			if (inCheck && checkMoveDict.size() - 1 < checkCount && checkMoveDict.get(whiteKingCell).empty()):
				#checkmate
				disableSelect = true
				var pop = get_parent().get_node("winPopup/menuImg")
				pop.texture = load("res://img/blackWin.png")
				pop = get_parent().get_node("winPopup")
				pop.visible = true
			elif ((checkMoveDict.size() - 1 < checkCount || (anyMoves(6, 13))) && checkMoveDict.get(whiteKingCell).empty()):
				#stalemate
				disableSelect = true
				var pop = get_parent().get_node("winPopup/menuImg")
				pop.texture = load("res://img/stalemate.png")
				pop = get_parent().get_node("winPopup")
				pop.visible = true
		else:
			kingMove(0, 7, blackKingCell, 9, 10, 1, 11, 7, 12)
			pawnKnightCheck(blackKingCell, 9, 10, 1)
			indirectDiagonalCheck(0, 7, 11, 7, blackKingCell)
			indirectCrossCheck(0, 7, 11, 12, blackKingCell)
			castle(0, 7, blackKingCell, 9, 10, 1, 11, 7, 12, blackKingMoved, blackKingRookMoved, blackQueenRookMoved)
			if (!indirectCheckMoveDict.empty() || inCheck):
				findMoves(0, 7)
			if (inCheck && checkMoveDict.size() - 1 < checkCount && checkMoveDict.get(blackKingCell).empty()):
				#checkmate
				disableSelect = true
				var pop = get_parent().get_node("winPopup/menuImg")
				pop.texture = load("res://img/whiteWin.png")
				pop = get_parent().get_node("winPopup")
				pop.visible = true
			elif ((checkMoveDict.size() - 1 < checkCount || (anyMoves(0, 7))) && checkMoveDict.get(blackKingCell).empty()):
				#stalemate
				disableSelect = true
				var pop = get_parent().get_node("winPopup/menuImg")
				pop.texture = load("res://img/stalemate.png")
				pop = get_parent().get_node("winPopup")
				pop.visible = true
	if (!disableSelect):
		hover()
		if (Input.is_action_just_released("on_left_click")):
			if (whiteTurn):
				select(6, 13)
			else:
				select(0, 7)

func anyMoves(start, end):
	for i in get_used_cells():
		var tempCell = get_cellv(i)
		if tempCell > start && tempCell < end:
			if checkMoveDict.has(i):
				if !checkMoveDict.get(i).empty():
					return false
			else:
				return false
	return true

func pawnKnightCheck(kingCell, knight, pawn, pawnDir):
	# puts cells into finalCheckList if pawn or knigh is checking king
	#knight:
	var temp_x = kingCell.x - 1
	var temp_y = kingCell.y + 2
	#-1, +2
	if (get_cell(temp_x, temp_y) == knight):
		finalCheckList.append(Vector2(temp_x, temp_y))
	temp_y -= 4
	#-1, -2
	if (get_cell(temp_x, temp_y) == knight):
		finalCheckList.append(Vector2(temp_x, temp_y))
	#+1, -2
	temp_x += 2
	if (get_cell(temp_x, temp_y) == knight):
		finalCheckList.append(Vector2(temp_x, temp_y))
	#+1, +2
	temp_y += 4
	if (get_cell(temp_x, temp_y) == knight):
		finalCheckList.append(Vector2(temp_x, temp_y))
	#+2, +1
	temp_x += 1
	temp_y -= 1
	if (get_cell(temp_x, temp_y) == knight):
		finalCheckList.append(Vector2(temp_x, temp_y))
	temp_y -= 2
	#+2, -1
	if (get_cell(temp_x, temp_y) == knight):
		finalCheckList.append(Vector2(temp_x, temp_y))
	temp_x -= 4
	#-2, -1
	if (get_cell(temp_x, temp_y) == knight):
		finalCheckList.append(Vector2(temp_x, temp_y))
	temp_y += 2
	#-2, +1
	if (get_cell(temp_x, temp_y) == knight):
		finalCheckList.append(Vector2(temp_x, temp_y))
	#pawn:
	if (get_cell(kingCell.x + 1, kingCell.y + pawnDir) == pawn):
		finalCheckList.append(Vector2(kingCell.x + 1, kingCell.y + pawnDir))
	if (get_cell(kingCell.x - 1, kingCell.y + pawnDir) == pawn):
		finalCheckList.append(Vector2(kingCell.x - 1, kingCell.y + pawnDir))
	if (!finalCheckList.empty()):
		inCheck = true

func findMoves(start, end):
	var tiles = get_used_cells()
	var tempCell
	if (inCheck):
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
	else:
		for i in indirectCheckMoveDict:
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
	var found = false
	if (indirectCheckMoveDict.has(tempKey)):
		#indirectCheck
		if (checkMoveDict.has(tempKey)):
			realMoves = checkMoveDict.get(tempKey)
		potentialMoves = indirectCheckMoveDict.get(tempKey)
		for i in moveArray:
			tempCell = get_cellv(i)
			if (tempCell == -1):
				if i in potentialMoves:
					realMoves.append(i)
			else:
				if i in potentialMoves:
					realMoves.append(i)
		checkMoveDict[Vector2(x_coord, y_coord)] = realMoves
	if (!checkMoveDict.has(tempKey) && inCheck):
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
	
func indirectDiagonalCheck(start, end, queen, bishop, kingCell, checkKing = false):
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
				if (checkKing):
					return true
				upperLeftCheck(temp_x, temp_y, space)
				inCheck = true
				checkCount += 1
			elif (!checkKing):
				if (indirectCheckMoveDict.has(Vector2(kingCell.x, kingCell.y))):
					checkList = indirectCheckMoveDict.get(Vector2(kingCell.x, kingCell.y))
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
				temp_x += 1
				temp_y += 1
				space -= 1
				while (space > 0):
					checkList.append(Vector2(temp_x, temp_y))
					temp_x += 1
					temp_y += 1
					space -= 1
				indirectCheckMoveDict[Vector2(peice_x, peice_y)] = checkList.duplicate()
				checkList.clear()
				checkCount += 1
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
				if (checkKing):
					return true
				upperRightCheck(temp_x, temp_y, space)
				inCheck = true
				checkCount += 1
			elif (!checkKing):
				if (indirectCheckMoveDict.has(Vector2(kingCell.x, kingCell.y))):
					checkList = indirectCheckMoveDict.get(Vector2(kingCell.x, kingCell.y))
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
				temp_x -= 1
				temp_y += 1
				space -= 1
				while (space > 0):
					checkList.append(Vector2(temp_x, temp_y))
					temp_x -= 1
					temp_y += 1
					space -= 1
				indirectCheckMoveDict[Vector2(peice_x, peice_y)] = checkList.duplicate()
				checkList.clear()
				checkCount += 1
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
				if (checkKing):
					return true
				lowerLeftCheck(temp_x, temp_y, space)
				inCheck = true
				checkCount += 1
			elif (!checkKing):
				if (indirectCheckMoveDict.has(Vector2(kingCell.x, kingCell.y))):
					checkList = indirectCheckMoveDict.get(Vector2(kingCell.x, kingCell.y))
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
				temp_x += 1
				temp_y -= 1
				space -= 1
				while (space > 0):
					checkList.append(Vector2(temp_x, temp_y))
					temp_x += 1
					temp_y -= 1
					space -= 1
				indirectCheckMoveDict[Vector2(peice_x, peice_y)] = checkList.duplicate()
				checkList.clear()
				checkCount += 1
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
				if (checkKing):
					return true
				lowerRightCheck(temp_x, temp_y, space)
				inCheck = true
				checkCount += 1
			elif (!checkKing):
				if (indirectCheckMoveDict.has(Vector2(kingCell.x, kingCell.y))):
					checkList = indirectCheckMoveDict.get(Vector2(kingCell.x, kingCell.y))
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
				temp_x -= 1
				temp_y -= 1
				space -= 1
				while (space > 0):
					checkList.append(Vector2(temp_x, temp_y))
					temp_x -= 1
					temp_y -= 1
					space -= 1
				indirectCheckMoveDict[Vector2(peice_x, peice_y)] = checkList.duplicate()
				checkList.clear()
				checkCount += 1
		if (count == 2):
			#two pieces protecting king we dont care about the rest
			break
	return false

func indirectCrossCheck(start, end, queen, rook, kingCell, checkKing = false):
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
				if (checkKing):
					return true
				upCheck(temp_coord, kingCell.x, space)
				inCheck = true
				checkCount += 1
			elif (!checkKing):
				if (indirectCheckMoveDict.has(Vector2(kingCell.x, kingCell.y))):
					checkList = indirectCheckMoveDict.get(Vector2(kingCell.x, kingCell.y))
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
				temp_coord += 1
				space -= 1
				while (space > 0):
					checkList.append(Vector2(kingCell.x, temp_coord))
					temp_coord += 1
					space -= 1
				indirectCheckMoveDict[Vector2(kingCell.x, peice_coord)] = checkList.duplicate()
				checkList.clear()
				checkCount += 1
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
				if (checkKing):
					return true
				downCheck(temp_coord, kingCell.x, space)
				inCheck = true
				checkCount += 1
			elif (!checkKing):
				if (indirectCheckMoveDict.has(Vector2(kingCell.x, kingCell.y))):
					checkList = indirectCheckMoveDict.get(Vector2(kingCell.x, kingCell.y))
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
				temp_coord -= 1
				space -= 1
				while (space > 0):
					checkList.append(Vector2(kingCell.x, temp_coord))
					temp_coord -= 1
					space -= 1
				indirectCheckMoveDict[Vector2(kingCell.x, peice_coord)] = checkList.duplicate()
				checkList.clear()
				checkCount += 1
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
				if (checkKing):
					return true
				rightCheck(temp_coord, kingCell.y, space)
				inCheck = true
				checkCount += 1
			elif (!checkKing):
				if (indirectCheckMoveDict.has(Vector2(kingCell.x, kingCell.y))):
					checkList = indirectCheckMoveDict.get(Vector2(kingCell.x, kingCell.y))
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
				temp_coord -= 1
				space -= 1
				while (space > 0):
					checkList.append(Vector2(temp_coord, kingCell.y))
					temp_coord -= 1
					space -= 1
				indirectCheckMoveDict[Vector2(peice_coord, kingCell.y)] = checkList.duplicate()
				checkList.clear()
				checkCount += 1
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
				if (checkKing):
					return true
				leftCheck(temp_coord, kingCell.y, space)
				inCheck = true
				checkCount += 1
			elif (!checkKing):
				if (indirectCheckMoveDict.has(Vector2(kingCell.x, kingCell.y))):
					checkList = indirectCheckMoveDict.get(Vector2(kingCell.x, kingCell.y))
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
				temp_coord += 1
				space -= 1
				while (space > 0):
					checkList.append(Vector2(temp_coord, kingCell.y))
					temp_coord += 1
					space -= 1
				indirectCheckMoveDict[Vector2(peice_coord, kingCell.y)] = checkList.duplicate()
				checkList.clear()
				checkCount += 1
		if (count == 2):
			#two pieces protecting king we dont care about the rest
			break
	return false

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
	var tempCell
	if (check):
		# pawns in start position
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
		if (pawn_coord != null):
			if (y_coord == pawn_coord.y && (x_coord == pawn_coord.x - 1 || x_coord == pawn_coord.x + 1)):
				moveTileMap.set_cell(pawn_coord.x, pawn_coord.y + pawnDir, 1)
	
func pawnPromotion(knight, bishop, rook, queen):
	#pawn made it to the other end can turn into queen, bishop, rook, or knight
	var temp = get_parent().get_node("ppPopup/HBoxContainer/0/bishopImg")
	if (bishop == 1):
		temp.texture = load("res://img/BB.png")
	else:
		temp.texture = load("res://img/WB.png")
	
	temp = get_parent().get_node("ppPopup/HBoxContainer/1/knightImg")
	if (knight == 3):
		temp.texture = load("res://img/BKT.png")
	else:
		temp.texture = load("res://img/WKT.png")
		
	temp = get_parent().get_node("ppPopup/HBoxContainer/3/queenImg")
	if (queen == 5):
		temp.texture = load("res://img/BQ.png")
	else:
		temp.texture = load("res://img/WQ.png")
		
	temp = get_parent().get_node("ppPopup/HBoxContainer/2/rookImg")
	if (rook == 6):
		temp.texture = load("res://img/BR.png")
	else:
		temp.texture = load("res://img/WR.png")
		
	var pop = get_parent().get_node("ppPopup")
	pop.visible = true
	
	yield(get_parent().get_node("ppPopup/HBoxContainer/0"), "pressed")
	pop.hide()
	print(temp)

func _pp_pressed(button):
	if (pawnBool):
		return
	var diff = 0
	if (whiteTurn):
		diff = 6
	match int(button.name):
		0:
			#bishop
			setMove(pawn_coord, 1 + diff, selectedCell)
		1:
			#knight
			setMove(pawn_coord, 3 + diff, selectedCell)
		2:
			#rook
			setMove(pawn_coord, 6 + diff, selectedCell)
		3:
			#queen
			setMove(pawn_coord, 5 + diff, selectedCell)
	pawnBool = true
	get_parent().get_node("ppPopup/HBoxContainer/0").emit_signal("pressed")

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
	var temp
	up(start, end, check)
	down(start, end, check)
	left(start, end, check)
	right(start, end, check)
	if (check):
		temp = indirectCheckMoveDict.get(Vector2(x_coord, y_coord))
	
func bishopMove(start, end, check = false):
	#bishop is selected display cells where they can move
	var temp
	upperLeft(start, end, check)
	upperRight(start, end, check)
	lowerLeft(start, end, check)
	lowerRight(start, end, check)
	if (check):
		temp = indirectCheckMoveDict.get(Vector2(x_coord, y_coord))
	
func kingMove(start, end, kingCell, knight, pawn, pawnDir, queen, bishop, rook):
	#king is selected display cells where they can move
	var temp
	#up/down
	moveArray.append(Vector2(kingCell.x, kingCell.y + 1))
	moveArray.append(Vector2(kingCell.x, kingCell.y - 1))
	#left/right
	moveArray.append(Vector2(kingCell.x + 1, kingCell.y))
	moveArray.append(Vector2(kingCell.x - 1, kingCell.y))
	# diagonals
	moveArray.append(Vector2(kingCell.x + 1, kingCell.y - 1))
	moveArray.append(Vector2(kingCell.x - 1, kingCell.y - 1))
	moveArray.append(Vector2(kingCell.x + 1, kingCell.y + 1))
	moveArray.append(Vector2(kingCell.x - 1, kingCell.y + 1))
	for i in moveArray.duplicate():
		temp = get_cellv(i)
		if (temp > start && temp < end || temp == 13):
			moveArray.erase(i)
	for i in moveArray.duplicate():
		if (checkKingMove(start, end, i, knight, pawn, pawnDir, queen, bishop, rook)):
			moveArray.erase(i)
	checkMoveDict[kingCell] = moveArray.duplicate()
	moveArray.clear()
		
func castle(start, end, kingCell, knight, pawn, pawnDir, queen, bishop, rook, kingMoved, kingRook, queenRook):
	#castling rules: https://youtu.be/FcLYgXCkucc?list=PL-qLOQ-OEls79TrVo14c9pN0sWwvli6rP
	# no peice between rook and king
	# castling can occur on king side and queen side
	# castling cannot occur if king is in check
	# castling cannot occur if king or rook has made a move
	# castling cannot occur if king will pass space that would be in check
	# castling cannot occur if king will be in check after move
	var tempList = checkMoveDict.get(kingCell)
	if !kingMoved:
		if !queenRook:
			if Vector2(kingCell.x - 1, kingCell.y) in tempList:
				if (get_cell(kingCell.x - 2, kingCell.y) == -1 && get_cell(kingCell.x - 3, kingCell.y) == -1):
					if !(checkKingMove(start, end, Vector2(kingCell.x - 2, kingCell.y), knight, pawn, pawnDir, queen, bishop, rook)):
						tempList.append(Vector2(kingCell.x - 2, kingCell.y))
		if !kingRook:
			if Vector2(kingCell.x + 1, kingCell.y) in tempList:
				if (get_cell(kingCell.x + 2, kingCell.y) == -1):
					if !(checkKingMove(start, end, Vector2(kingCell.x + 2, kingCell.y), knight, pawn, pawnDir, queen, bishop, rook)):
						tempList.append(Vector2(kingCell.x + 2, kingCell.y))

func checkKingMove(start, end, kingCell, knight, pawn, pawnDir, queen, bishop, rook):
	#knight:
	var temp_x = kingCell.x - 1
	var temp_y = kingCell.y + 2
	#-1, +2
	if (get_cell(temp_x, temp_y) == knight):
		return true
	temp_y -= 4
	#-1, -2
	if (get_cell(temp_x, temp_y) == knight):
		return true
	#+1, -2
	temp_x += 2
	if (get_cell(temp_x, temp_y) == knight):
		return true
	#+1, +2
	temp_y += 4
	if (get_cell(temp_x, temp_y) == knight):
		return true
	#+2, +1
	temp_x += 1
	temp_y -= 1
	if (get_cell(temp_x, temp_y) == knight):
		return true
	temp_y -= 2
	#+2, -1
	if (get_cell(temp_x, temp_y) == knight):
		return true
	temp_x -= 4
	#-2, -1
	if (get_cell(temp_x, temp_y) == knight):
		return true
	temp_y += 2
	#-2, +1
	if (get_cell(temp_x, temp_y) == knight):
		return true
	#pawn:
	if (get_cell(kingCell.x + 1, kingCell.y + pawnDir) == pawn):
		return true
	if (get_cell(kingCell.x - 1, kingCell.y + pawnDir) == pawn):
		return true
		
	#king:
	if whiteTurn:
		if abs(kingCell.x - blackKingCell.x) < 2 && abs(kingCell.y - blackKingCell.y) < 2:
			return true
	else:
		if abs(kingCell.x - whiteKingCell.x) < 2 && abs(kingCell.y - whiteKingCell.y) < 2:
			return true
		
	if (indirectDiagonalCheck(start, end, queen, bishop, kingCell, true)):
		return true
	else:
		return indirectCrossCheck(start, end, queen, rook, kingCell, true)
	
func queenMove(start, end, check = false):
	#queen is selected display cells where they can move
	var temp 
	upperLeft(start, end, check)
	upperRight(start, end, check)
	lowerLeft(start, end, check)
	lowerRight(start, end, check)
	up(start, end, check)
	down(start, end, check)
	left(start, end, check)
	right(start, end, check)
	if (check):
		temp = indirectCheckMoveDict.get(Vector2(x_coord, y_coord))
		
func upperLeft(start, end, check = false):
	#upper left diagonal
	var temp_x = x_coord
	var temp_y = y_coord
	while (temp_x > 1 && temp_y > 1):
		temp_x -= 1
		temp_y -= 1
		moveArray.append(Vector2(temp_x, temp_y))
	if (check):
		evaluateMoves()
	else:
		showMoves(start, end)

func upperRight(start, end, check = false):
	# upper right diagonal
	var temp_x = x_coord
	var temp_y = y_coord
	while (temp_x < 8 && temp_y > 1):
		temp_x += 1
		temp_y -= 1
		moveArray.append(Vector2(temp_x, temp_y))
	if (check):
		evaluateMoves()
	else:
		showMoves(start, end)
	
func lowerLeft(start, end, check = false):
	# lower left diagonal
	var temp_x = x_coord
	var temp_y = y_coord
	while (temp_x > 1 && temp_y < 8):
		temp_x -= 1
		temp_y += 1
		moveArray.append(Vector2(temp_x, temp_y))
	if (check):
		evaluateMoves()
	else:
		showMoves(start, end)
		
func lowerRight(start, end, check = false):
	# lower right diagonal
	var temp_x = x_coord
	var temp_y = y_coord
	while (temp_x < 8 && temp_y < 8):
		temp_x += 1
		temp_y += 1
		moveArray.append(Vector2(temp_x, temp_y))
	if (check):
		evaluateMoves()
	else:
		showMoves(start, end)
		
func up(start, end, check = false):
	#up
	var temp = y_coord
	while (temp > 1):
		temp -= 1
		moveArray.append(Vector2(x_coord, temp))
	if (check):
		evaluateMoves()
	else:
		showMoves(start, end)
		
func down(start, end, check = false):
#	#down
	var temp = y_coord
	while (temp < 8):
		temp += 1
		moveArray.append(Vector2(x_coord, temp))
	if (check):
		evaluateMoves()
	else:
		showMoves(start, end)

func left(start, end, check = false):
#	#left
	var temp = x_coord
	while (temp > 1):
		temp -= 1
		moveArray.append(Vector2(temp, y_coord))
	if (check):
		evaluateMoves()
	else:
		showMoves(start, end)

func right(start, end, check = false):
#	#right
	var temp = x_coord
	while (temp < 8):
		temp += 1
		moveArray.append(Vector2(temp, y_coord))
	if (check):
		evaluateMoves()
	else:
		showMoves(start, end)

func makeMove():
	# on mouse release if clicked on possible move 
	# set previous cell to empty and new cell to cellID
	#clear highlight tilemap
	var temp = get_cellv(selectedCell)
	if (moveTileMap.get_cellv(cell) > 0):
		if (temp == 2):
			#black king
			# for castling
			if (!blackKingMoved):
				if blackKingCell.x - cell.x > 1:
					setMove(Vector2(cell.x + 1, cell.y), 6, Vector2(cell.x - 2, cell.y))
				elif blackKingCell.x - cell.x < -1:
					setMove(Vector2(cell.x - 1, cell.y), 6, Vector2(cell.x + 1, cell.y))
			blackKingMoved = true
			blackKingCell = cell
		elif (temp == 8):
			# white King
			# for castling
			if (!whiteKingMoved):
				if whiteKingCell.x - cell.x > 1:
					setMove(Vector2(cell.x + 1, cell.y), 12, Vector2(cell.x - 2, cell.y))
				elif whiteKingCell.x - cell.x < -1:
					setMove(Vector2(cell.x - 1, cell.y), 12, Vector2(cell.x + 1, cell.y))
			whiteKingMoved = true
			whiteKingCell = cell
		elif (temp == 4):
			#black pawn
			if (cell.y == 4 && selectedCell.y == 2):
				#en passant
				pawn_coord = cell
				pawnCount = 1
			elif (cell.y == 8):
				#promotion
				disableSelect = true
				pawn_coord = cell
				yield(pawnPromotion(3, 1, 6, 5), "completed")
				resetTurn()
				return
			elif (pawn_coord != null):
				if (cell.y == pawn_coord.y + 1 && cell.x == pawn_coord.x):
					set_cellv(pawn_coord, - 1)
		elif (temp == 10):
			#white pawn
			if (cell.y == 5 && selectedCell.y == 7):
				#en passant
				pawn_coord = cell
				pawnCount = 1
			elif (cell.y == 1):
				#promotion
				disableSelect = true
				pawn_coord = cell
				yield(pawnPromotion(6, 7, 12, 11), "completed")
				resetTurn()
				return
			elif (pawn_coord != null):
				if (cell.y == pawn_coord.y - 1 && cell.x == pawn_coord.x):
					set_cellv(pawn_coord, - 1)
		elif (cell.x == 8 && cell.y == 8 || selectedCell.x == 8 && selectedCell.y == 8):
			whiteKingRookMoved = true
		elif (cell.x == 1 && cell.y == 1 || selectedCell.x == 1 && selectedCell.y == 1):
			blackQueenRookMoved = true
		elif (cell.x == 8 && cell.y == 1 || selectedCell.x == 8 && selectedCell.y == 1):
			blackKingRookMoved = true
		elif (cell.x == 1 && cell.y == 8 || selectedCell.x == 1 && selectedCell.y == 8):
			whiteQueenRookMoved = true
		setMove(cell, temp, selectedCell)
		resetTurn()
		
func setMove(cell_one, id_one, cell_two, id_two = -1):
	set_cellv(cell_one, id_one)
	set_cellv(cell_two, id_two)

func resetTurn():
	highlightTileMap.set_cellv(selectedCell, -1)
	selectedCell = emptyCell
	moveTileMap.clear()
	if (whiteTurn):
		blackGear.visible = true
		whiteGear.hide()
		whiteTurn = false
	else:
		whiteGear.visible = true
		blackGear.hide()
		whiteTurn = true
	if pawnCount > 0:
		pawnCount -= 1
	else:
		pawn_coord = null
	inCheck = false
	checked = false
	checkList.clear()
	finalCheckList.clear()
	checkMoveDict.clear()
	indirectCheckMoveDict.clear()
	checkCount = 0
	pawnBool = false
	disableSelect = false

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
						if cell in indirectCheckMoveDict:
							for j in indirectCheckMoveDict[cell]:
								if j in finalCheckList:
									tempCell = get_cellv(i)
									if (tempCell == -1):
										# move is putting piece between king and opponent
										moveTileMap.set_cellv(j, 2)
									else:
										# move is killing opponents piece
										moveTileMap.set_cellv(j, 1)
						else:
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
		


func _on_drawBtn_pressed():
	var pop = get_parent().get_node("optionPopup")
	pop.hide()
	pop = get_parent().get_node("drawPopup")
	pop.visible = true


func _on_resignBtn_pressed():
	disableSelect = true
	var pop = get_parent().get_node("winPopup/menuImg")
	if (whiteTurn):
		pop.texture = load("res://img/blackWin.png")
	else:
		pop.texture = load("res://img/whiteWin.png")
	pop = get_parent().get_node("winPopup")
	pop.visible = true

func _on_quitBtn_pressed():
	get_tree().reload_current_scene()

func _on_closeBtn_pressed():
	var pop = get_parent().get_node("optionPopup")
	pop.hide()
	disableSelect = false

func _on_optionBtn_pressed():
	disableSelect = true
	highlightTileMap.set_cellv(selectedCell, -1)
	selectedCell = emptyCell
	moveTileMap.clear()
	var pop = get_parent().get_node("optionPopup")
	pop.visible = true

func _on_noBtn_pressed():
	var pop = get_parent().get_node("drawPopup")
	pop.hide()
	disableSelect = false

func _on_yesBtn_pressed():
	var pop = get_parent().get_node("drawPopup")
	pop.hide()
	pop = get_parent().get_node("winPopup/menuImg")
	pop.texture = load("res://img/draw.png")
	pop = get_parent().get_node("winPopup")
	pop.visible = true

func _on_playAgainBtn_pressed():
	get_tree().reload_current_scene()

func _on_playBtn_pressed():
	var pop = get_parent().get_node("menuPopup")
	pop.hide()
	disableSelect = false
