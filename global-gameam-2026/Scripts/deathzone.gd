extends Area3D

func _respawn(body: CharacterBody3D) -> void:
	var spawn = get_tree().get_first_node_in_group("SpawnPoint")
	if spawn:
		body.global_position = spawn.global_position
		body.velocity = Vector3.ZERO

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_respawn(body)
