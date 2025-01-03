extends Player
class_name WizardPlayer

@export var spells : Array[WizardSpell] = []
@export var spell_circle : MeshInstance3D
@export var spell_hint : Label

@onready var current_spell : int = 0


var consuming_mouse_movement : bool = false

func _ready() -> void:
	dash_multiplier = 0


func _client_setup() -> void:
	if !is_node_ready():
		await ready
	if !is_multiplayer_authority():
		$WizardUI.visible = false
	else:
		$WizardUI.visible = true
		var circle_rotation = spell_circle.rotation_degrees.z
		if circle_rotation < 0:
			circle_rotation = circle_rotation + 360
		var selecting_spell : int = (round(circle_rotation / 60) as int) % 6
		spell_hint.text = "Current Spell: " + spells[selecting_spell].spell_name
		spells[selecting_spell].select(get_path())


@onready var spell : WizardSpell = spells[current_spell]
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
				current_spell = (round(circle_rotation / 60) as int) % 6
				spell_circle.rotation_degrees.z = current_spell * 60
				spell_hint.text = "Current Spell: " + spells[current_spell].spell_name
				if spells[current_spell] != spell:
					spell.deselect(get_path())
					spell = spells[current_spell]
					spell.select(get_path())
	
	if not (event is InputEventMouseMotion
	and consuming_mouse_movement):
		super(event)
	elif is_multiplayer_authority():
		event = event as InputEventMouseMotion
		var to_rotate = event.relative.x / 200.
		spell_circle.rotate_z(-to_rotate)
		var circle_rotation = spell_circle.rotation_degrees.z
		if circle_rotation < 0:
			circle_rotation = circle_rotation + 360
		current_spell = (round(circle_rotation / 60) as int) % 6
		spell_hint.text = "Current Spell: " + spells[current_spell].spell_name
		


@rpc("call_local", "authority")
func cast_spell(spell_id : int, path : NodePath):
	spells[spell_id].use(path)
