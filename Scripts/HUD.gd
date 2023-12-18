extends Control

var heart = preload("res://Assets/heart.tscn")
var heart5 = preload("res://Assets/heart_5.tscn")

func _process(delta):
	update_hearts(get_node('..').lives)
	$Score.text = str(get_node('..').score)
	$HiScore.text = 'High: '+str(get_node('..').hi_score)

func update_hearts(lives):
	var lives_shown = len(get_tree().get_nodes_in_group('heart5')) * 5 + len(get_tree().get_nodes_in_group('heart'))
	if lives_shown == lives: return
	for h in get_tree().get_nodes_in_group('heart5') + get_tree().get_nodes_in_group('heart'):
		h.queue_free()
	
	var heart_ptr = [Vector2.ZERO]
	var inst_heart = func inst_heart(heart):
		var heart_i = heart.instantiate()
		$Hearts.add_child(heart_i)
		var sf = heart_i.size.x / heart_i.size.y
		heart_i.position = heart_ptr[0]
		heart_i.size = Vector2($Hearts.size.y*sf, $Hearts.size.y)
		heart_ptr[0].x += heart_i.size.x
	var heart5_count = int(lives/5)
	for i in range(heart5_count):
		inst_heart.call(heart5)
	lives -= heart5_count * 5
	for i in range(lives):
		inst_heart.call(heart)
