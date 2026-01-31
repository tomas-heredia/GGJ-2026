extends StaticBody3D

var time = 2

func _ready():
	set_process(false)

func _process(_delta):
	time += 1
	$Sprite3D.position += Vector3(0, sin(time) * 2, 0)

func _on_area_3d_body_entered(body: Node3D):
	if body.name == 'player':
		set_process(true)
		$Timer.start(0.7)

func _on_timer_timeout():
	queue_free()
