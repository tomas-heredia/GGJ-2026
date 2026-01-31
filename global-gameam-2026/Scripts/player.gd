extends CharacterBody3D

@export var walk_speed:= 5.0
@export var sprint_speed:= 9.0
@export var accel:= 18.0
@export var decel:= 22.0
@export var jump_velocity:= 4.5
@export var double_jump:= true
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var current_speed: float = 0.0

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Double Jump
	if double_jump and Input.is_action_just_pressed("jump") and !is_on_floor():
		velocity.y = jump_velocity
		
	#Jump
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Input (left / right only)
	var x_input := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	# Choose target speed
	var target_speed: float = walk_speed
	if Input.is_action_pressed("sprint"):
		target_speed = sprint_speed

	# Smooth acceleration / deceleration
	if (abs(x_input)) > 0.001:
		current_speed = move_toward(current_speed, target_speed, accel * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, decel * delta)

	# Apply movement
	velocity.x = x_input * current_speed
	velocity.z = 0.0

	move_and_slide()
