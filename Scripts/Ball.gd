extends RigidBody2D

@export var START_SPEED = 700
@export var SPEED_UP = 5
var current_speed: float
var original_pos : Vector2
var velocity : Vector2

var Rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	original_pos = position
	current_speed = START_SPEED
	reset(false)	# Aim at player 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var collide_info = move_and_collide(velocity * delta)
	var collide_sound = get_node("CollideSound")
	if collide_info:
		var Collider = collide_info.get_collider()
		if Collider.get_collision_layer() == 1:	# Paddles
			var speed = velocity.length()
			var direction = (position - Collider.position).normalized()
			velocity = speed * direction
			collide_sound.set_pitch_scale(2)
		else:
			velocity = velocity.bounce(collide_info.get_normal())
			collide_sound.set_pitch_scale(1)
		
		if Collider.get_collision_layer() == 4:	# Breakable Bricks
			Collider.queue_free()
			current_speed += SPEED_UP
			velocity = current_speed*velocity.normalized()
			print(current_speed)
			print(velocity.length())
		collide_sound.play()
	rotation = 0	# Prevent rotation due to sandwiching

# Moves ball back to starting position
func reset(keep_speed = true):
	position = original_pos
	velocity = Vector2.ZERO
	if not keep_speed:
		current_speed = START_SPEED
	$Timer.start()

func shoot_ball():
	velocity = current_speed * Vector2.RIGHT.rotated(PI/4)
	var collide_sound = get_node("CollideSound")
	collide_sound.set_pitch_scale(3)
	collide_sound.play()
