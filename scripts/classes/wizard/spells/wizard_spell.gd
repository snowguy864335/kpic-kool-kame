extends Resource
class_name WizardSpell

@export var spell_name : String = "Default"

func use(_player : NodePath) -> bool:
	push_warning("Default spell used!")
	return false

func select(_player : NodePath) -> void:
	pass

func deselect(_player : NodePath) -> void:
	pass
