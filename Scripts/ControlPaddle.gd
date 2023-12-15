extends StaticBody2D

@export var speed : int
@export var is_human : bool

enum AI_Type {
	RANDOM, FOLLOW, FOLLOW_STICKY,
	FOLLOW_CORRUPT, FOLLOW_CORRUPT_STICKY,
	TRAJECTORY, TRAJECTORY_NO_REFLECT}
@export var ai_type : AI_Type

var Rng = RandomNumberGenerator.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var motion = Vector2.RIGHT * speed * delta
	motion *= human_control() if is_human else cpu_control()
	move_and_collide(motion)

func human_control():
	if Input.is_action_pressed('ui_left'):
		return -1
	if Input.is_action_pressed('ui_right'):
		return 1
	return 0

@export var UPDATE_INTERVAL = 20
var countdown = 0
var dir = 0
func random_ai():
	countdown -= 1
	if countdown <= 0:
		dir = Rng.randi_range(-1, 1)
		countdown = UPDATE_INTERVAL
	return dir

# Follow ball
func follow_ai():
	var Ball = get_node("../Ball")
	return (Ball.position.x - position.x)/abs(Ball.position.x - position.x)

# Follow but with sticky controls (direction does not change for interval)
func follow_sticky():
	countdown -= 1
	if countdown <= 0:
		dir = follow_ai()
		countdown = UPDATE_INTERVAL
	return dir

# Follow with corruption (random chance of going opposite direction)
@export var CORRUPT_CHANCE = 0.8
func follow_corrupt():
	if Rng.randf() > CORRUPT_CHANCE:
		return follow_ai() * -1
	return follow_ai()

# Sticky follow with corruption
func follow_corrupt_sticky():
	countdown -= 1
	if countdown <= 0:
		dir = follow_corrupt()
		countdown = UPDATE_INTERVAL
	return dir

# Positions to ball's trajectory
func trajectory_ai():
	# All the objects we need
	var Ball = get_node("../Ball")
	var Floor = get_node("../Wall")
	var Ceil = get_node("../Wall2")

	var Dy = position.y - Ball.position.y

	# Do nothing if ball going opposite
	if Ball.velocity.y * Dy <= 0:
		return 0;

	var dx = Ball.velocity.x / Ball.velocity.y * Dy # Projected position
	var x = Ball.position.x
	var x_min = Ceil.position.x
	var x_max = Floor.position.x
	var ball_h = Ball.get_node('CollisionShape2D').shape.size.x
	# Reflect trajectory until within bounds
	while x + dx < x_min or x_max < x + dx:
		var x_b = x_min + ball_h/2 if x + dx < x_min else x_max - ball_h/2
		dx -= 2 * (x+dx-x_b)

	var Dx = x + dx - position.x
	if abs(Dx) < 10:
		return 0
	return 1 if Dx > 0 else -1

# Positions to ball's trajectory (may be off bounds)
func trajectory_non_reflect():
	# All the objects we need
	var Ball = get_node("../Ball")

	var Dy = position.y - Ball.position.y

	# Do nothing if ball going opposite
	if Ball.velocity.y * Dy <= 0:
		return 0;

	var dx = Ball.velocity.x / Ball.velocity.y * Dy # Projected position
	var x = Ball.position.x

	var Dx = x + dx - position.x
	if abs(Dx) < 10:
		return 0
	return 1 if Dx > 0 else -1

func cpu_control():
	if ai_type == AI_Type.RANDOM:
		return random_ai()
	elif ai_type == AI_Type.FOLLOW:
		return follow_ai()
	elif ai_type == AI_Type.FOLLOW_STICKY:
		return follow_sticky()
	elif ai_type == AI_Type.FOLLOW_CORRUPT:
		return follow_corrupt()
	elif ai_type == AI_Type.FOLLOW_CORRUPT_STICKY:
		return follow_corrupt_sticky()
	elif ai_type == AI_Type.TRAJECTORY:
		return trajectory_ai()
	elif ai_type == AI_Type.TRAJECTORY_NO_REFLECT:
		return trajectory_non_reflect()
	
