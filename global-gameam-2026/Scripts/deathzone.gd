extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_respawn(body)

func _respawn(body: CharacterBody3D) -> void:
	# Teleport the player to the last saved checkpoint.
	body.global_position = Global.last_checkpoint_position
	body.velocity = Vector3.ZERO
