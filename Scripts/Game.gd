extends Node2D

@export var lives = 3
var score = 0

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
	print("Score" + str(score))
