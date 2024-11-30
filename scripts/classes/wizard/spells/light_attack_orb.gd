extends WizardSpell
class_name LightAttackOrb

@export var orb_scene : PackedScene

var mana_cost : int = 10
var cooldown : float = 2

func use(player : NodePath) -> bool:
	var playerNode = Engine.get_main_loop().current_scene.get_node(player)
	var orb : Area3D  = orb_scene.instantiate()
	orb.transform = playerNode.camera.global_transform
	playerNode.get_tree().current_scene.add_child(orb)
	return true
