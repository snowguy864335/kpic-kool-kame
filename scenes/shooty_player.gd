extends Player
class_name ShootyPlayer

func _unhandled_input(event):
	super(event)
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var space_state = get_world_3d().direct_space_state
			var mousepos = get_viewport().get_mouse_position()
			var origin = camera.project_ray_origin(mousepos)
			var end = origin + camera.project_ray_normal(mousepos) * 1000
			var query = PhysicsRayQueryParameters3D.create(origin, end)
			var result = space_state.intersect_ray(query)
			print(result)
