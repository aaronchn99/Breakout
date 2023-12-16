extends RigidBody2D

@export var start_speed = 700
@export var SPEED_UP = 5
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
		if Collider.get_collision_layer() == 1:	# Paddles
			var speed = velocity.length()
			var direction = (position - Collider.position).normalized()
			velocity = speed * direction
			collide_sound.set_pitch_scale(2)
		else:
			velocity = velocity.bounce(collide_info.get_normal())
			collide_sound.set_pitch_scale(1)
		
		if Collider.get_collision_layer() == 4:
			Collider.queue_free()
			velocity *= start_speed+SPEED_UP
			velocity /= start_speed
			start_speed += SPEED_UP
			print(start_speed)
			print(velocity.length())
		collide_sound.play()
	rotation = 0	# Prevent rotation due to sandwiching

# Moves ball back to starting position
func reset():
	position = original_pos
	velocity = Vector2.ZERO
	$Timer.start()

func shoot_ball():
	# Start 45deg from down, random chance to 135deg, reverse if p2
	velocity = start_speed * Vector2.RIGHT.rotated(PI*(0.5+Rng.randi_range(0, 1))/2)
	var collide_sound = get_node("CollideSound")
	collide_sound.set_pitch_scale(3)
	collide_sound.play()
