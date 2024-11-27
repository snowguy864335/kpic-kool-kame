extends WizardSpell
class_name LightningDash


func use(player : WizardPlayer) -> bool:
	var space_state = player.get_world_3d().direct_space_state
	var start = player.camera.global_position
	var end = start - player.camera.global_basis.z * 10
	
	var ray_cast_parameters = PhysicsRayQueryParameters3D.create(start, end)

	var result = space_state.intersect_ray(ray_cast_parameters)
	if result:
		player.global_position = result["position"]
	else:
		player.global_position = end
	
	
	return true
