extends Node2D

@export var MAX_LIVES = 3
var lives
var score = 0
var hi_score = 0

var brick_p = preload("res://Assets/brick.tscn")

var brick_map : Dictionary

func generate_map(brick_map):
	for b in get_tree().get_nodes_in_group('brick'):
		$Bricks.remove_child(b)
		b.queue_free()
	
	var gap = brick_map.gap
	var w = ($Bricks.size.x + gap) / brick_map.columns - gap
	var h = ($Bricks.size.y + gap) / brick_map.rows - gap
	for b in brick_map.bricks:
		var repeat = 1 if len(b) < 4 else b[3]
		for i in range(repeat):
			var brick = brick_p.instantiate()
			$Bricks.add_child(brick)
			brick.set_color(Color(brick_map.colors[b[2]]))
			brick.set_size(w, h)
			brick.position = Vector2((b[0]+i)*(w+gap)+w/2,b[1]*(h+gap)+h/2)

func _ready():
	restart()

func _process(delta):
	if lives == 0 and not $GameOver.visible:
		$GameOver.visible = true
		get_tree().paused = true
	elif $Bricks.get_child_count() == 0 and not $GameWin.visible:
		$GameWin.visible = true
		get_tree().paused = true

func _on_paddle_miss(body):
	print("Paddle Missed :(")
	lives -= 1
	$Ball.reset()

func _on_brick_collide(body):
	score += 1
	print("Score: " + str(score))

func restart():
	hi_score = max(hi_score, score)
	$GameOver.visible = false
	$GameWin.visible = false
	$Pause/PauseMenu.visible = false
	generate_map(brick_map)
	lives = MAX_LIVES
	score = 0
	$Ball.reset()
	get_tree().paused = false

func _back_to_menu():
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()
