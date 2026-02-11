extends CharacterBody3D

var speed
const WALK_SPEED = 5.0 # default value is '5.0'
const SPRINT_SPEED = 8.0
#const JUMP_VELOCITY = 20.0
const SENSITIVITY = 0.008

#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

# sfx vars
var footstep_can_play := true
var footstep_landed

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var sfx_footstep: AudioStreamPlayer3D = $sfx_footstep


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	## Handle Jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()

	if not footstep_landed and is_on_floor(): # Landed
		sfx_footstep.play()
	footstep_landed = is_on_floor()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	var footstep_threshold = -BOB_AMP + 0.002
	if pos.y > footstep_threshold:
		footstep_can_play = true
	elif pos.y < footstep_threshold and footstep_can_play:
		footstep_can_play = false
		sfx_footstep.play()
	return pos
