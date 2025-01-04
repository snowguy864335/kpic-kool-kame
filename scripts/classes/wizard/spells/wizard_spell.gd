extends Resource
class_name WizardSpell

@export var spell_name : String = "Default"

func use(player : NodePath) -> bool:
	push_warning("Default spell used!")
	return false

func select(player : NodePath) -> void:
	pass

func deselect(player : NodePath) -> void:
	pass
