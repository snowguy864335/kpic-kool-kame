extends WizardSpell
class_name WindDash

var mana_cost : int = 10
var cooldown : float = 2
var dash_velocity : float = 20

func use(player : NodePath) -> bool:
	var playerNode = Engine.get_main_loop().current_scene.get_node(player)
	playerNode.velocity -= playerNode.camera.global_basis.z * dash_velocity
	return true
