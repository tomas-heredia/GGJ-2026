extends StaticBody3D

var count = 0

func _on_character_body_3d_change() -> void:
	count += 1
	if count % 2 == 1:
		$CollisionShape3D.hide()
		$MeshInstance3D.hide()
		position += Vector3(0, -10000, 0)
	else:
		$CollisionShape3D.show()
		$MeshInstance3D.show()
		position -= Vector3(0, -10000, 0)
