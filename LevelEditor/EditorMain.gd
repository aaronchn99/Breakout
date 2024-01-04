extends Control

@export var LEVEL_FILE : String

var empty_brick = preload("res://LevelEditor/Bricks/empty_brick.tscn")
var break_brick = preload("res://LevelEditor/Bricks/breakable_brick.tscn")
var unbreak_brick = preload("res://LevelEditor/Bricks/unbreakable_brick.tscn")

var level_list
var brick_array : Array
var selected_brick:
	set(brick):
		$Bricks/CursorRect.position = brick.position - Vector2.ONE
		$Bricks/CursorRect.size = brick.size + 3*Vector2.ONE
		$Bricks/CursorRect.visible = true

var gap : float
var rows : int
var columns : int
var brick_w : float
var brick_h : float

# Brick Factory method
# 	prefab	Resource	Preloaded scene of brick
#	c		int 		column (or x coordinate)
#	r		int			row (or y coordinate)
#	Returns instantiated brick Node
func create_brick(prefab : Resource, c : int, r : int):
	var brick = prefab.instantiate()
	$Bricks.add_child(brick)
	brick.set_size(Vector2(brick_w, brick_h))
	brick.position = Vector2(c*(brick_w+gap),r*(brick_h+gap))
	brick.set_meta('Coordinates', Vector2i(c, r))
	if brick_array[r][c]:
		brick_array[r][c].queue_free()
	brick_array[r][c] = brick
	brick.gui_input.connect(on_brick_gui_event.bind(brick))
	return brick

func generate_map(brick_map):
	# Clean out bricks
	for b in get_tree().get_nodes_in_group('brick'):
		$Bricks.remove_child(b)
		b.queue_free()
	$Bricks/CursorRect.visible = false
	
	gap = brick_map.gap
	rows = brick_map.rows
	columns = brick_map.columns
	brick_w = ($Bricks.size.x + gap) / columns - gap
	brick_h = ($Bricks.size.y + gap) / rows - gap
	brick_array = range(rows).map(func(r):
		return range(columns).map(func(c):
			return null
		)
	)
	
	# init with empty bricks
	for r in range(rows):
		for c in range(columns):
			var brick = create_brick(empty_brick, c, r)
	
	for brick_data in brick_map.bricks:
		var repeat = 1 if not 'repeat' in brick_data else brick_data.repeat
		var b = brick_data.pos
		var brick_p = break_brick
		if 'breakable' in brick_data and not brick_data.breakable:
			brick_p = unbreak_brick
		for i in range(repeat):
			var brick = create_brick(brick_p, b[0]+i, b[1])
			if 'color' in brick_data:
				brick.set_color(Color(brick_map.colors[brick_data.color]))

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load level file
	var f = FileAccess.open(LEVEL_FILE, FileAccess.READ)
	var json = JSON.new()
	assert(not json.parse(f.get_as_text()), 'Error parsing json')
	assert(typeof(json.data) == TYPE_ARRAY, 'Parse data expected Array ('+str(TYPE_ARRAY)+') got '+str(typeof(json.data)))
	level_list = json.data
	f.close()
	generate_map(level_list[0])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# When a brick has been clicked
func on_brick_gui_event(event : InputEvent, brick):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			selected_brick = brick
