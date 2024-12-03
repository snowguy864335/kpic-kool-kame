extends WizardSpell
class_name IceWallSpell

@export var wall_scene : PackedScene

@export var mana_cost : int = 10
@export var cooldown : float = 2

var cooldown_timer : Timer

func use(player : NodePath) -> bool:
	var playerNode : Node3D = Engine.get_main_loop().current_scene.get_node(player)
	
	if not cooldown_timer:
		cooldown_timer = Timer.new()
		cooldown_timer.wait_time = cooldown
		cooldown_timer.one_shot = true
		cooldown_timer.name = "IceWallCooldownTimer"
		playerNode.add_child(cooldown_timer)
	
	if cooldown_timer.time_left == 0:
		var wall : Node3D = wall_scene.instantiate()
		wall.transform = playerNode.global_transform.translated(-playerNode.global_basis.z * 2)
		playerNode.add_sibling(wall)
		return true
	return false
