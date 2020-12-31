extends TileMap

onready var highlight = get_parent().get_node("highlight")
var whiteTurn : bool = true
var last
var cell
var selectedCell
var emptyCell
var cellID

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO set up board
	emptyCell = world_to_map(get_global_mouse_position().snapped(Vector2(0, 0)))
	last = emptyCell
	selectedCell = emptyCell

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hover()
	if (whiteTurn):
		select(6, 13)
	else:
		select(0, 7)

func hover():
	cell = world_to_map(get_global_mouse_position().snapped(Vector2(0, 0)))
	cellID = get_cellv(cell)
	if (cell != last && last != selectedCell && cell != selectedCell):
		if (cellID != 13):
			highlight.set_cellv(cell, 0)
		highlight.set_cellv(last, -1)
	if (cell == selectedCell && last != selectedCell):
		highlight.set_cellv(last, -1)
	if (last == selectedCell && cell != selectedCell):
		if (cellID != 13):
			highlight.set_cellv(cell, 0)
	last = cell

func select(x, y):
	if (Input.is_action_just_released("on_left_click")):
		if (cellID > x && cellID < y):
			if (cell != selectedCell):
				highlight.set_cellv(selectedCell, -1)
				selectedCell = cell
				highlight.set_cellv(cell, 5)
			else:
				highlight.set_cellv(selectedCell, 0)
				selectedCell = emptyCell
