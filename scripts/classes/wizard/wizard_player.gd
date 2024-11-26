extends Player
class_name WizardPlayer

@export var spells : Array[WizardSpell] = []
@export var spell_circle : MeshInstance3D

@onready var current_spell : WizardSpell = spells[1]

var consuming_mouse_movement : bool = false

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseMotion
	and consuming_mouse_movement):
		super(event)
	else:
		event = event as InputEventMouseMotion
		var mesh = spell_circle.mesh as QuadMesh
		spell_circle.rotate_z(-event.relative.x / 200.)
	
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT
		and event.is_pressed()):
			current_spell.use(self)
	
	if event is InputEventKey:
		if event.keycode == KEY_R:
			if event.is_pressed():
				consuming_mouse_movement = true
			else:
				consuming_mouse_movement = false
		
