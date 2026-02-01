extends StaticBody3D

var count = 0
var materialTransparent = preload("res://transparentMaterial.tres")
var materialWhite = preload("res://whiteMaterial.tres")

func _ready() -> void:
	Signals.connect("Change",_on_character_body_3d_change)
	$CollisionShape3D.disabled = true
	$MeshInstance3D.set_surface_override_material(0, materialTransparent)

func _on_character_body_3d_change() -> void:
	count += 1
	if count % 2 == 1:
		$CollisionShape3D.disabled = false
		$MeshInstance3D.set_surface_override_material(0, materialWhite)
		if count != 1:
			pass
	else:
		$CollisionShape3D.disabled = true
		$MeshInstance3D.set_surface_override_material(0, materialTransparent)
