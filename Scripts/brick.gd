extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.texture.set_local_to_scene(true)
	$Sprite.texture.gradient.set_local_to_scene(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_color(color: Color):
	$Sprite.texture.gradient.colors[0] = color

func set_size(w: float, h: float):
	$Collider.shape.size.x *= w / $Collider.shape.size.x
	$Collider.shape.size.y *= h / $Collider.shape.size.y
	$Sprite.scale.x *= w / $Sprite.scale.x
	$Sprite.scale.y *= h / $Sprite.scale.y