extends Player
class_name WizardPlayer

@export var spells : Array[WizardSpell] = []
@export var spell_circle : MeshInstance3D

@onready var current_spell : WizardSpell = spells[0]

var consuming_mouse_movement : bool = false

func _unhandled_input(event: InputEvent) -> void:
	
	
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
				var circle_rotation = spell_circle.rotation_degrees.z
				if circle_rotation < 0:
					circle_rotation = circle_rotation + 360
				var selected_spell : int = (round(circle_rotation / 60) as int) % 6
				spell_circle.rotation_degrees.z = selected_spell * 60
				current_spell = spells[selected_spell]
				
	if not (event is InputEventMouseMotion
	and consuming_mouse_movement):
		super(event)
	else:
		event = event as InputEventMouseMotion
		spell_circle.rotate_z(-event.relative.x / 200.)
