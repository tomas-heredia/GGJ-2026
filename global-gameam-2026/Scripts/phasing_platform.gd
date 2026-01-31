extends StaticBody3D

var time = 1

func _ready():
	if $StaticBody3D.name == "PhasingPlatform":
		pass
	else:
		pass

func _on_mesh_instance_3d_visibility_changed() -> void:
	pass 


func _on_timer_timeout() -> void:
	pass # Replace with function body.
