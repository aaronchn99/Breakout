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

# Instantiates given preloaded node, connecting signals
# 	Returns new instance
func create_brick(prefab):
	var brick = prefab.instantiate()
	$Bricks.add_child(brick)
	brick.gui_input.connect(on_brick_gui_event.bind(brick))
	return brick

func generate_map(brick_map):
	# Clean out bricks
	for b in get_tree().get_nodes_in_group('brick'):
		$Bricks.remove_child(b)
		b.queue_free()
	brick_array = []
	$Bricks/CursorRect.visible = false
	
	var gap = brick_map.gap
	var w = ($Bricks.size.x + gap) / brick_map.columns - gap
	var h = ($Bricks.size.y + gap) / brick_map.rows - gap
	
	# init with empty bricks
	for r in range(brick_map.rows):
		var brick_row = []
		for c in range(brick_map.columns):
			var brick = create_brick(empty_brick)
			brick.set_size(Vector2(w, h))
			brick.position = Vector2(c*(w+gap),r*(h+gap))
			brick_row.append(brick)
		brick_array.append(brick_row)
	
	for brick_data in brick_map.bricks:
		var repeat = 1 if not 'repeat' in brick_data else brick_data.repeat
		var b = brick_data.pos
		var brick_p = break_brick
		if 'breakable' in brick_data and not brick_data.breakable:
			brick_p = unbreak_brick
		for i in range(repeat):
			var brick = create_brick(brick_p)
			if 'color' in brick_data:
				brick.set_color(Color(brick_map.colors[brick_data.color]))
			brick.set_size(Vector2(w, h))
			brick.position = Vector2((b[0]+i)*(w+gap),b[1]*(h+gap))
			if brick_array[b[1]][b[0]+i]:
				brick_array[b[1]][b[0]+i].queue_free()
			brick_array[b[1]][b[0]+i] = brick

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

func on_brick_gui_event(event : InputEvent, brick):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			selected_brick = brick
