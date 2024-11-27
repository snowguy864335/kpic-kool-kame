extends WizardSpell
class_name WindDash

var mana_cost : int = 10
var cooldown : float = 2
var dash_velocity : float = 20

func use(player : WizardPlayer) -> bool:
	player.velocity -= player.camera.global_basis.z * dash_velocity
	return true
