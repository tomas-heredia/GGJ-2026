extends StaticBody3D

var time = 1

func _ready():
	set_process(false)

func _process(_delta):
	time += 1
	$MeshInstance3D.position += Vector3(0, sin(time) * 0.02, 0)

func hiding():
	$CollisionShape3D.hide()
	$MeshInstance3D.hide()
	$Area3D.hide()

func showing():
	$CollisionShape3D.show()
	$MeshInstance3D.show()
	$Area3D.show()

func _on_area_3d_body_entered(body: Node3D):
	if body.name == 'CharacterBody3D':
		set_process(true)
		$Timer.start()

func _on_timer_timeout():
	print("Breaking platform timer stop.")
	$Timer.stop()
	position += Vector3(0, -10000, 0)
	set_process(false)
	hiding()
	$Timer2.start()

func _on_timer_2_timeout():
	$Timer2.stop()
	position += Vector3(0, 10000, 0)
	showing()
