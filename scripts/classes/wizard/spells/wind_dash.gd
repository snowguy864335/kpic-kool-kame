extends WizardSpell
class_name WindDash

@export var dash_velocity : float = 50
@export var mana_cost : int = 10
@export var cooldown : float = 2


func use(player : NodePath) -> bool:
	var playerNode = Engine.get_main_loop().current_scene.get_node(player)
	playerNode.velocity -= playerNode.camera.global_basis.z * dash_velocity
	return true
