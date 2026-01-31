extends StaticBody3D

var time = 1

func _ready():
	set_process(false)

func _process(_delta):
	time += 1
	$MeshInstance3D.position += Vector3(0, sin(time) * 0.02, 0)

func _on_area_3d_body_entered(body: Node3D):
	if body.name == 'CharacterBody3D':
		set_process(true)
		$Timer.start()

func _on_timer_timeout():
	print("Timer stop.")
	queue_free()
