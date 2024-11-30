extends Player
class_name WizardPlayer

@export var spells : Array[WizardSpell] = []
@export var spell_circle : MeshInstance3D

@onready var current_spell : int

var consuming_mouse_movement : bool = false

func _unhandled_input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT
		and event.is_pressed()):
			cast_spell.rpc(current_spell, get_path())
	
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
				current_spell = selected_spell
	
	if not (event is InputEventMouseMotion
	and consuming_mouse_movement):
		super(event)
	elif is_multiplayer_authority():
		event = event as InputEventMouseMotion
		spell_circle.rotate_z(-event.relative.x / 200.)

@rpc("call_local", "authority")
func cast_spell(spell_id : int, path : NodePath):
	spells[spell_id].use(path)
