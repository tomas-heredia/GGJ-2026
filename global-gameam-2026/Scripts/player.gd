extends CharacterBody3D

@export var walk_speed:= 5.0
@export var sprint_speed:= 9.0
@export var accel:= 18.0
@export var decel:= 22.0
@export var jump_velocity:= 4.5
@export var jump_count := 0
@export var mask_double_jump:= false
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var face_socket: Node3D = $Marker3D

var current_speed: float = 0.0

#MOVEMENT
func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	
	# Mask 1 = Double Jump
	if is_on_floor():
		jump_count = 0
		
	if mask_double_jump and Input.is_action_just_pressed("jump") and !is_on_floor() and jump_count < 1:
		velocity.y = jump_velocity
		jump_count += 1
		
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
	

# Mask EQUP MECHANICS	
var nearby_mask: Node3D = null
var equipped_mask: Node3D = null

func _process(_delta: float) -> void:
	if nearby_mask and Input.is_action_just_pressed("interact"):
		equip_mask(nearby_mask)
		mask_double_jump = true

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
	var area := mask.get_node_or_null("Area3D") as Area3D
	if area:
		area.monitoring = false
		area.monitorable = false

	equipped_mask = mask
	nearby_mask = null
	
	
