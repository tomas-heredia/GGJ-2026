extends Control

@onready var credits_screen: ColorRect = $Credits_screen



func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level/level_1.tscn")


func _on_credits_pressed() -> void:
	credits_screen.show()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_button_pressed() -> void:
	credits_screen.hide()
