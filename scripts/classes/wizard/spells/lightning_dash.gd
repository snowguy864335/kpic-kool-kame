extends WizardSpell
class_name LightningDash

@export var effect_scene : PackedScene

@export var max_dash_distance = 10

@export var mana_cost : int = 10
@export var cooldown : float = 2

var cooldown_timer : Timer

func use(player : NodePath) -> bool:
	var playerNode : Node3D = Engine.get_main_loop().current_scene.get_node(player)
	

	if not cooldown_timer:
		cooldown_timer = Timer.new()
		cooldown_timer.wait_time = cooldown
		cooldown_timer.one_shot = true
		cooldown_timer.name = "LightningDashCooldownTimer"
		playerNode.add_child(cooldown_timer)
	
	if cooldown_timer.time_left == 0:
		var effect : LightningDashEffect = effect_scene.instantiate()
		playerNode.get_parent().add_child(effect)
		var space_state = playerNode.get_world_3d().direct_space_state
		var start = playerNode.camera.global_position
		var end = start - playerNode.camera.global_basis.z * max_dash_distance
		
		var ray_cast_parameters = PhysicsRayQueryParameters3D.create(start, end)

		var result = space_state.intersect_ray(ray_cast_parameters)
		if result:
			playerNode.global_position = result["position"] + Vector3.DOWN
		else:
			playerNode.global_position = end + Vector3.DOWN
		effect.play_out(playerNode.global_position)
		cooldown_timer.start()
		
		return true
	return false
