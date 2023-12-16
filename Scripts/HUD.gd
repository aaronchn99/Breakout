extends Control


func _process(delta):
	$Lives.text = str($/root/Game.lives) + ' lives'
