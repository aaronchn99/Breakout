extends Control

func _pause_toggle():
	get_tree().paused = not get_tree().paused
	$PauseMenu.visible = not $PauseMenu.visible
