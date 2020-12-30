extends TileMap

var last
var cell

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	last = world_to_map(get_global_mouse_position().snapped(Vector2(0, 0)))
	# set up board


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cell = world_to_map(get_global_mouse_position().snapped(Vector2(0, 0)))
	if (cell != last):
		set_cellv(cell, 0)
		set_cellv(last, -1)
	last = cell
