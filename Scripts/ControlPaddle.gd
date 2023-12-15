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
	var motion = Vector2.DOWN * speed * delta
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
	return (Ball.position.y - position.y)/abs(Ball.position.y - position.y)

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
	var Floor = get_node("../Floor")
	var Ceil = get_node("../Ceiling")

	var Dx = position.x - Ball.position.x

	# Do nothing if ball going opposite
	if Ball.velocity.x * Dx <= 0:
		return 0;

	var dy = Ball.velocity.y / Ball.velocity.x * Dx # Projected position
	var y = Ball.position.y
	var y_min = Ceil.position.y
	var y_max = Floor.position.y
	var ball_h = Ball.get_node('CollisionShape2D').shape.size.y
	# Reflect trajectory until within bounds
	while y + dy < y_min or y_max < y + dy:
		var y_b = y_min + ball_h/2 if y + dy < y_min else y_max - ball_h/2
		dy -= 2 * (y+dy-y_b)

	var Dy = y + dy - position.y
	if abs(Dy) < 10:
		return 0
	return 1 if Dy > 0 else -1

# Positions to ball's trajectory (may be off bounds)
func trajectory_non_reflect():
	# All the objects we need
	var Ball = get_node("../Ball")
	var Floor = get_node("../Floor")
	var Ceil = get_node("../Ceiling")

	var Dx = position.x - Ball.position.x

	# Do nothing if ball going opposite
	if Ball.velocity.x * Dx <= 0:
		return 0;

	var dy = Ball.velocity.y / Ball.velocity.x * Dx # Projected position
	var y = Ball.position.y

	var Dy = y + dy - position.y
	if abs(Dy) < 10:
		return 0
	return 1 if Dy > 0 else -1

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
	
