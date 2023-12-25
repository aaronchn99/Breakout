extends Control

var game_scene = preload("res://Game.tscn")
var level_button = preload("res://Assets/UI/level_button.tscn")
var level_list : Array
@export var LEVEL_FILE : String

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load levels
	var f = FileAccess.open(LEVEL_FILE, FileAccess.READ)
	var json = JSON.new()
	assert(not json.parse(f.get_as_text()), 'Error parsing json')
	assert(typeof(json.data) == TYPE_ARRAY, 'Parse data expected Array ('+str(TYPE_ARRAY)+') got '+str(typeof(json.data)))
	level_list = json.data
	f.close()
	for i in range(len(level_list)):
		var btn = level_button.instantiate()
		btn.text = str(i + 1)
		btn.button_down.connect(func(): _play(i))
		$LevelMenu/Levels.add_child(btn)
	if OS.get_name() == "Web":
		$QuitButton.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _level_menu():
	$LevelMenu.visible = true
	$PlayButton.visible = false
	if $QuitButton: $QuitButton.visible = false

func _main_menu():
	$LevelMenu.visible = false
	$PlayButton.visible = true
	if $QuitButton: $QuitButton.visible = true

func _play(level : int):
	visible = false
	var GameNode = game_scene.instantiate()
	GameNode.brick_map = level_list[level]
	$/root.add_child(GameNode)


func _quit():
	get_tree().quit()
