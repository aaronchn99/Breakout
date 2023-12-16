extends Node2D

@export var lives = 3

func _on_paddle_miss(body):
	print("Paddle Missed :(")
	lives -= 1
	if lives == 0:
		$GameOver.visible = true
		get_tree().paused = true
		return
	$Ball.reset()
