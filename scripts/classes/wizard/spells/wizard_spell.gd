extends Resource
class_name WizardSpell

@export var spell_name : String = "Default"

func use(player : NodePath) -> bool:
	push_warning("Default spell used!")
	return false
