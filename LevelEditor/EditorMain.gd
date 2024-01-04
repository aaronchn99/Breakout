extends Control

@export var LEVEL_FILE : String

var empty_brick = preload("res://LevelEditor/Bricks/empty_brick.tscn")
var break_brick = preload("res://LevelEditor/Bricks/breakable_brick.tscn")
var unbreak_brick = preload("res://LevelEditor/Bricks/unbreakable_brick.tscn")
var brick_types = [empty_brick, break_brick, unbreak_brick]

var level_list
var selected_level : int
var brick_array : Array
var selected_brick:
	set(brick):
		if not brick == null:
			$Bricks/CursorRect.position = brick.position - Vector2.ONE
			$Bricks/CursorRect.size = brick.size + 3*Vector2.ONE
			$Bricks/CursorRect.visible = true
			
			var coords = brick.get_meta('Coordinates')
			var i = $EditPanel/BrickType/OptionButton.selected
			var color = null
			if $EditPanel/Color.visible:
				color = $EditPanel/Color/ColorPickerButton.color
			brick = create_brick(brick_types[i], coords.x, coords.y, color)
		selected_brick = brick

var gap : float:
	set(val):
		level_list[selected_level].gap = val
		$EditPanel/Gap/SpinBox.set_value_no_signal(val)
		gap = val
var rows : int:
	set(val):
		level_list[selected_level].rows = val
		$EditPanel/Row/SpinBox.set_value_no_signal(val)
		rows = val
var columns : int:
	set(val):
		level_list[selected_level].columns = val
		$EditPanel/Column/SpinBox.set_value_no_signal(val)
		columns = val
var brick_w : float
var brick_h : float

# Brick Factory method
# 	prefab	Resource	Preloaded scene of brick
#	c		int 		column (or x coordinate)
#	r		int			row (or y coordinate)
#	Returns instantiated brick Node
func create_brick(prefab : Resource, c : int, r : int, color = null):
	var brick = prefab.instantiate()
	$Bricks.add_child(brick)
	brick.set_size(Vector2(brick_w, brick_h))
	brick.position = Vector2(c*(brick_w+gap),r*(brick_h+gap))
	if color != null: brick.set_color(color)
	brick.set_meta('Coordinates', Vector2i(c, r))
	if brick_array[r][c]:
		brick_array[r][c].queue_free()
	brick_array[r][c] = brick
	brick.gui_input.connect(on_brick_gui_event.bind(brick))
	return brick

func generate_map(brick_map):
	# Clean out bricks and reset cursor
	for b in get_tree().get_nodes_in_group('brick'):
		$Bricks.remove_child(b)
		b.queue_free()
	$Bricks/CursorRect.visible = false
	selected_brick = null
	
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
		if b[1] >= rows: continue
		if 'breakable' in brick_data and not brick_data.breakable:
			brick_p = unbreak_brick
		for i in range(repeat):
			var color = null
			if b[0]+i >= columns: continue
			if 'color' in brick_data and brick_data.color != null:
				color = Color(brick_map.colors[brick_data.color])
			create_brick(brick_p, b[0]+i, b[1], color)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load level file
	var f = FileAccess.open(LEVEL_FILE, FileAccess.READ)
	var json = JSON.new()
	assert(not json.parse(f.get_as_text()), 'Error parsing json')
	assert(typeof(json.data) == TYPE_ARRAY, 'Parse data expected Array ('+str(TYPE_ARRAY)+') got '+str(typeof(json.data)))
	level_list = json.data
	f.close()
	for i in range(len(level_list)):
		$EditPanel/Level/OptionButton.add_item(str(i+1))
	
	on_level_change($EditPanel/Level/OptionButton.selected)
	on_change_brick_type($EditPanel/BrickType/OptionButton.selected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# When a brick has been clicked
func on_brick_gui_event(event : InputEvent, brick):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			selected_brick = brick
			level_list[selected_level].dirty = true

# When BrickType option changed
func on_change_brick_type(type):
	$EditPanel/Color.visible = type == 1
	if selected_brick:
		selected_brick = selected_brick
		level_list[selected_level].dirty = true

func on_color_change(color : Color):
	if selected_brick:
		selected_brick = selected_brick
		level_list[selected_level].dirty = true

func on_level_change(level):
	if len(brick_array):
		store_level()
	selected_level = level
	generate_map(level_list[level])

func on_row_change(val):
	rows = val
	generate_map(level_list[selected_level])
	level_list[selected_level].dirty = true

func on_col_change(val):
	columns = val
	generate_map(level_list[selected_level])
	level_list[selected_level].dirty = true

func on_gap_change(val):
	gap = val
	generate_map(level_list[selected_level])
	level_list[selected_level].dirty = true

# Stores currently displayed bricks to level_list. Called on level change and save
func store_level():
	if not 'dirty' in level_list[selected_level]: return
	var colors = {}
	var bricks = []
	for i in range(len(brick_array)):
		for j in range(len(brick_array[i])):
			if brick_array[i][j].is_in_group('empty'): continue
			var brick = {'pos': [j, i]}
			brick.breakable = brick_array[i][j].is_in_group('breakable')
			brick.color = null
			if brick.breakable:
				var color_code = brick_array[i][j].color.to_html()
				brick.color = color_code
				colors[color_code] = '#' + color_code
			bricks.append(brick)
	level_list[selected_level].colors = colors
	level_list[selected_level].bricks = bricks

# 
func save():
	store_level()
	var is_identical = func(b1, b2):
		return b1.color == b2.color and b1.breakable == b2.breakable
	# RLE Compression
	for i in range(len(level_list)):
		if not 'dirty' in level_list[i]: continue	# Skip unaffected levels
		level_list[i].erase('dirty')
		var new_bricks = []
		var leading = null
		var count = 1
		for b in level_list[i].bricks:
			if leading == null:
				leading = b
			elif is_identical.call(leading, b) and leading.pos[1] == b.pos[1] \
				and leading.pos[0] + count == b.pos[0]:
				count += 1
			else:
				if count > 1: leading.repeat = count
				new_bricks.append(leading)
				leading = b
				count = 1
		if leading != null:
			if count > 1: leading.repeat = count
			new_bricks.append(leading)
		level_list[i].bricks = new_bricks
	# Save to json file
	var f = FileAccess.open(LEVEL_FILE, FileAccess.WRITE)
	var json = JSON.stringify(level_list, '\t')
	f.store_string(json)
	f.close()
