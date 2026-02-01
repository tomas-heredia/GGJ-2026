extends Area3D

@onready var spawn_point: Marker3D = $Marker3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		# Overwrite the global respawn position with this checkpoint's marker.
		Global.last_checkpoint_position = spawn_point.global_position
