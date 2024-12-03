extends WizardSpell
class_name WindDash

@export var dash_velocity : float = 50
@export var mana_cost : int = 10
@export var cooldown : float = 4

var cooldown_timer : Timer

func use(player : NodePath) -> bool:
	var playerNode : WizardPlayer = Engine.get_main_loop().current_scene.get_node(player)
	if not cooldown_timer:
		cooldown_timer = Timer.new()
		cooldown_timer.wait_time = cooldown
		cooldown_timer.one_shot = true
		cooldown_timer.name = "WindDashCooldownTimer"
		playerNode.add_child(cooldown_timer)
		
	if cooldown_timer.time_left == 0:
		var dash_force = playerNode.camera.global_basis.z * dash_velocity
		dash_force.y *= 0.5
		playerNode.velocity -= dash_force
		cooldown_timer.start()
		return true
	return false
