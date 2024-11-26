extends WizardSpell
class_name LightAttackOrb

@export var orb_scene : PackedScene

var mana_cost : int = 10
var cooldown : float = 2

func use(player : WizardPlayer) -> void:
	var orb : Area3D  = orb_scene.instantiate()
	orb.transform = player.camera.global_transform
	player.get_tree().root.add_child(orb)
