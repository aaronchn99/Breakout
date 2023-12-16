extends Control


func _process(delta):
	$Lives.text = str($/root/Game.lives) + ' lives'
	$Score.text = str($/root/Game.score)
