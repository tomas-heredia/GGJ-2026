extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var mask: Node3D = $Area3D/mask

@onready var area: Area3D = $Area3D

enum MaskPower {
	NONE,
	DOUBLE_JUMP,      # Horizontal boost
	WALL_BOUNCE,      # Temporary platforms from jumps
	PHASE,
	FINAL,
}

@export var worn_mask: MaskPower = MaskPower.NONE

func _ready() -> void:
	
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	if worn_mask == MaskPower.FINAL:
		mask.scale = mask.scale * 8
		animation_player.play("final_animation")
	else:
		animation_player.play("Floting")
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.nearby_mask = self
		
	

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") and body.nearby_mask == self:
		body.nearby_mask = null

func stop_anim():
	animation_player.stop()
