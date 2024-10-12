extends Node3D

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
