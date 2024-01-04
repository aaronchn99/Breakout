extends RigidBody2D

var breakable = true :
	set(breakable):
		collision_layer = 4
		if not breakable:
			collision_layer = 2
			set_color(Color.WHITE)
			remove_from_group('breakable')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


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
