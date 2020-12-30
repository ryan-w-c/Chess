extends TileMap

onready var highlight = get_parent().get_node("highlight")
var whiteTurn : bool = true
var selected : bool = false
var last
var cell
var selectedCell

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# set up board
	last = world_to_map(get_global_mouse_position().snapped(Vector2(0, 0)))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	var mousePos = get_global_mouse_position()
#	var loc = world_to_map(mousePos)
#	var cell = get_cell(loc.x,loc.y)
#	set_cell(loc.x,loc.y,1)
	hover()
	if (whiteTurn):
		if (Input.is_action_pressed("on_left_click")):
			selectedCell = cell
			highlight.set_cellv(cell, 5)


func hover():
	cell = world_to_map(get_global_mouse_position().snapped(Vector2(0, 0)))
	if (cell != last):
		if (last != selectedCell):
			print(cell, last, selectedCell)
			highlight.set_cellv(cell, 0)
			highlight.set_cellv(last, -1)
	last = cell

