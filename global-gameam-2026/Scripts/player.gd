extends CharacterBody3D

@export var walk_speed := 5.0
@export var sprint_speed := 9.0
var current_direction: float = 0.0
@export var accel := 18.0
@export var decel := 22.0
@export var wall_slide_speed := 1.0
var wall_jump_cooldown: float = 0.0
@export var wall_jump_pushback := 100
@export var wall_jump_true = true
@export var jump_velocity := 4.5
var has_jumped := false
# Ability flags (driven by the equipped mask)
@export var mask_double_jump := false
@export var mask_wall_bounce := false
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var face_socket: Node3D = $Marker3D
@onready var mesh: Node3D = $MeshInstance3D
var current_speed: float = 0.0
var jumps_used: int = 0
# Mask equip vars (Mask.gd sets nearby_mask on enter/exit)
var nearby_mask: Node3D = null
var equipped_mask: Node3D = null

func _ready() -> void:
	Global.last_checkpoint_position = global_position

func _physics_process(delta: float) -> void:
	# Input (left / right only)
	var x_input := Input.get_axis("move_left", "move_right")

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

		# Wall friction / wall slide
		if mask_wall_bounce and is_on_wall():
			var wall_normal: Vector3 = get_wall_normal()
			var pushing_into_wall: bool = signf(x_input) == -signf(wall_normal.x)
			if pushing_into_wall:
				velocity.y = max(velocity.y, -wall_slide_speed)

	# Reset jumps when grounded
	if is_on_floor():
		jumps_used = 0
	
	# Handle no jump from floor
	var max_jumps = 1
	if mask_double_jump:
		max_jumps = 2

	# Jump / Double Jump 
	if Input.is_action_just_pressed("jump"):
		if jumps_used < max_jumps:
			velocity.y = jump_velocity
			jumps_used += 1

	# Wall Jump (only when wall-slide power is enabled)
	if mask_wall_bounce and is_on_wall() and Input.is_action_just_pressed("jump") and wall_jump_true:
		velocity.y = jump_velocity
		# Push away from wall using the wall normal
		velocity.x = get_wall_normal().x * wall_jump_pushback
		wall_jump_true = false
	
	if not is_on_wall():
		wall_jump_true = true
	
	# Choose target speed
	var target_speed: float = walk_speed
	if Input.is_action_pressed("sprint"):
		target_speed = sprint_speed

	# Smooth acceleration / deceleration
	if abs(x_input) > 0.001:
		current_direction = signf(x_input)
		current_speed = move_toward(current_speed, target_speed, accel * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, decel * delta)
	
	# Face direction of movement
	if current_direction != 0.0:
		mesh.scale.x = current_direction
	
	# Apply movement
	velocity.x = current_direction * current_speed
	velocity.z = 0.0
	move_and_slide()


# MASK MECHANICS
func _process(_delta: float) -> void:
	if nearby_mask and Input.is_action_just_pressed("interact"):
		equip_mask(nearby_mask)


# --- Mask power handling ---

func clear_mask_powers() -> void:
	mask_double_jump = false
	mask_wall_bounce = false

func apply_mask_power(power: int) -> void:
	clear_mask_powers()

	# We match against the enum defined in Mask.gd.
	# This works as long as the enum values are:
	# NONE=0, DOUBLE_JUMP=1, WALL_BOUNCE=2
	match power:
		0: # NONE
			pass
		1: # DOUBLE_JUMP
			mask_double_jump = true
		2: # WALL_BOUNCE (using this to enable wall slide/jump mechanics)
			mask_wall_bounce = true
		_:
			pass


func equip_mask(mask: Node3D) -> void:
	# If only one mask allowed, drop/replace old
	if equipped_mask:
		equipped_mask.queue_free()
		equipped_mask = null

	# Reparent the mask to the face socket
	mask.get_parent().remove_child(mask)
	face_socket.add_child(mask)

	# Snap to the socket
	mask.transform = Transform3D.IDENTITY

	# Disable pickup collider so it doesn’t keep triggering
	var pickup_area := mask.get_node_or_null("Area3D") as Area3D
	if pickup_area:
		pickup_area.monitoring = false
		pickup_area.monitorable = false

	equipped_mask = mask
	nearby_mask = null
	
	if "worn_mask" in mask:
		apply_mask_power(mask.worn_mask)
	else:
		clear_mask_powers()
		
