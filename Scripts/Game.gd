extends Node2D

func _on_paddle_miss(body):
	print("Paddle Missed :(")
	$Ball.reset()
