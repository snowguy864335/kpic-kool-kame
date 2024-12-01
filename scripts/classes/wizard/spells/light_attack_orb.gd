extends WizardSpell
class_name LightAttackOrbSpell

@export var orb_scene : PackedScene

@export var mana_cost : int = 10
@export var cooldown : float = 0.5

var cooldown_timer : Timer



func use(player : NodePath) -> bool:
	var playerNode : WizardPlayer = Engine.get_main_loop().current_scene.get_node(player)
	if not cooldown_timer:
		cooldown_timer = Timer.new()
		cooldown_timer.wait_time = cooldown
		cooldown_timer.one_shot = true
		cooldown_timer.name = "FireballCooldownTimer"
		playerNode.add_child(cooldown_timer)
	
	
	if cooldown_timer.time_left == 0:
		var orb : Fireball  = orb_scene.instantiate()
		orb.exclusion.append(playerNode)
		orb.transform = playerNode.camera.global_transform
		playerNode.get_tree().root.add_child(orb)
		cooldown_timer.start()
		return true
	else:
		return false
