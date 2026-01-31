extends Node3D

@onready var area: Area3D = $Area3D

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.nearby_mask = self

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") and body.nearby_mask == self:
		body.nearby_mask = null
