extends CharacterBody3D


@export var walk_speed := 3.0
@export var sprint_speed := 6.0
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
@export var mask_phase := false
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var face_socket: Node3D = $CharacterModel/Marker3D
@onready var mesh: Node3D = $CharacterModel/MeshInstance3D
@onready var anim: AnimationPlayer = $CharacterModel/AnimationPlayer
@onready var base_mesh_scale_x: float = abs(mesh.scale.x)
var current_speed: float = 0.0
var jumps_used: int = 0
# Mask equip vars (Mask.gd sets nearby_mask on enter/exit)
var nearby_mask: Node3D = null
var equipped_mask: Node3D = null

@onready var jump_sfx: AudioStreamPlayer3D = $JumpSfx
@onready var interaction_sfx: AudioStreamPlayer3D = $InteractionSfx
@onready var running_sfx: AudioStreamPlayer3D = $RunningSfx
var _sprint_sfx_playing := false

const ANIM_IDLE := "mixamo_com"
const ANIM_WALK := "mixamo_com_001"
const ANIM_RUN  := "mixamo_com_002"

var _current_anim: StringName = &""

func _play_anim(ani_name: StringName) -> void:
	if _current_anim == ani_name:
		return
	_current_anim = ani_name
	anim.play(ani_name)

func _ready() -> void:
	Global.last_checkpoint_position = global_position
	print(anim.get_animation_list())
	_play_anim(ANIM_IDLE)
	

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
			jump_sfx.play()
			

	# Wall Jump (only when wall-slide power is enabled)
	if mask_wall_bounce and is_on_wall() and Input.is_action_pressed("jump") and wall_jump_true:
		velocity.y = jump_velocity
		# Push away from wall using the wall normal
		velocity.x = get_wall_normal().x * wall_jump_pushback
		wall_jump_true = false
		jump_sfx.play()
	
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
	
	
	#Character Facing Direction
	if abs(x_input) > 0.001:
		current_direction = signf(x_input)
	var target_rot := PI/2 if current_direction > 0.0 else -PI/2
	$CharacterModel.rotation.y = lerp_angle($CharacterModel.rotation.y, target_rot, 0.2)


	# Apply movement
	velocity.x = current_direction * current_speed
	velocity.z = 0.0
	move_and_slide()
	
	
	# --- Sprint SFX loop ---
	var is_sprinting = Input.is_action_pressed("sprint") and abs(current_speed) > 0.001
	if is_sprinting and not _sprint_sfx_playing:
		running_sfx.play()
		_sprint_sfx_playing = true
	elif not is_sprinting and _sprint_sfx_playing or not is_on_floor():
		running_sfx.stop()
		_sprint_sfx_playing = false
	
	if Input.is_action_just_pressed("Phase") and mask_phase:
		
		Signals.Change.emit()
	
	# --- Animaions ---
	var moving = abs(current_speed) > 0.05
	var sprinting = Input.is_action_pressed("sprint") and moving
	if not is_on_floor():
		# You don't have a jump/fall clip, so pick a fallback:
		_play_anim(ANIM_WALK)  # or ANIM_WALK if you prefer
	elif not moving:
		_play_anim(ANIM_IDLE)
	elif sprinting:
		_play_anim(ANIM_RUN)
	else:
		_play_anim(ANIM_WALK)

# MASK MECHANICS
func _process(_delta: float) -> void:
	if nearby_mask and Input.is_action_just_pressed("interact"):
		equip_mask(nearby_mask)
		interaction_sfx.play()


# --- Mask power handling ---

func clear_mask_powers() -> void:
	mask_double_jump = false
	mask_wall_bounce = false
	mask_phase = false

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
		3:
			mask_phase = true
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
	mask.stop_anim()
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
		
