extends Resource
class_name WizardSpell

var spell_name : String = "Default"

func use(player : NodePath) -> bool:
	push_warning("Default spell used!")
	return false