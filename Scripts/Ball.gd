extends RigidBody2D

@export var start_speed = 700
var original_pos : Vector2
var velocity : Vector2

var Rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	original_pos = position
	reset()	# Aim at player 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var collide_info = move_and_collide(velocity * delta)
	var collide_sound = get_node("CollideSound")
	if collide_info:
		var Collider = collide_info.get_collider()
		if Collider.get_collision_layer() == 2: # Floor/Ceiling
			velocity = velocity.bounce(collide_info.get_normal())
			collide_sound.set_pitch_scale(1)
		else:	# Paddles
			var speed = velocity.length()
			var direction = (position - Collider.position).normalized()
			velocity = speed * direction
			collide_sound.set_pitch_scale(2)
		collide_sound.play()
	rotation = 0	# Prevent rotation due to sandwiching

# Moves ball back to starting position
func reset():
	position = original_pos
	# Start 45deg from down, random chance to 135deg, reverse if p2
	velocity = start_speed * Vector2.RIGHT.rotated(PI*(0.5+Rng.randi_range(0, 1))/2)
	var collide_sound = get_node("CollideSound")
	collide_sound.set_pitch_scale(3)
	collide_sound.play()
