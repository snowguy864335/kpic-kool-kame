extends WizardSpell
class_name LightningDash

func use(player : NodePath) -> bool:
	var playerNode = Engine.get_main_loop().current_scene.get_node(player)
	var space_state = playerNode.get_world_3d().direct_space_state
	var start = playerNode.camera.global_position
	var end = start - playerNode.camera.global_basis.z * 10
	
	var ray_cast_parameters = PhysicsRayQueryParameters3D.create(start, end)

	var result = space_state.intersect_ray(ray_cast_parameters)
	if result:
		playerNode.global_position = result["position"]
	else:
		playerNode.global_position = end
	
	
	return true
