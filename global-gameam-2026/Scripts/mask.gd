extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

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
	animation_player.play("Floting")
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.nearby_mask = self

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") and body.nearby_mask == self:
		body.nearby_mask = null

func stop_anim():
	animation_player.stop()
