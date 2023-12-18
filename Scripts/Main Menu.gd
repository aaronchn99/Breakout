extends Control

var game_scene = preload("res://Game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _play():
	visible = false
	$/root.add_child(game_scene.instantiate())


func _quit():
	get_tree().quit()
