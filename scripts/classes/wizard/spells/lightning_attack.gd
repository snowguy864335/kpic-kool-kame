extends WizardSpell
class_name LightningAttack

@export var hud_scene : PackedScene
@export var effect_scene : PackedScene

@export var mana_cost : int = 10
@export var cooldown : float = 2

var cooldown_timer : Timer

func use(player : NodePath) -> bool:
	var playerNode : WizardPlayer = Engine.get_main_loop().current_scene.get_node(player)
	

	if not cooldown_timer:
		cooldown_timer = Timer.new()
		cooldown_timer.wait_time = cooldown
		cooldown_timer.one_shot = true
		cooldown_timer.name = "LightningDashCooldownTimer"
		playerNode.add_child(cooldown_timer)
	
	if cooldown_timer.time_left == 0:
		var attack : LightningAttackScene  = effect_scene.instantiate()
		attack.transform = playerNode.camera.global_transform
		#attack.global_basis.z = playerNode.camera.global_basis.z
		playerNode.get_tree().root.add_child(attack)
		cooldown_timer.start()
		return true

	return false


var hud : SpellHud
func select(player : NodePath) -> void:
	var playerNode : WizardPlayer = Engine.get_main_loop().current_scene.get_node(player)
	if not cooldown_timer:
		cooldown_timer = Timer.new()
		cooldown_timer.wait_time = cooldown
		cooldown_timer.one_shot = true
		cooldown_timer.name = "LightningAttackCooldownTimer"
		playerNode.add_child(cooldown_timer)
	
	if playerNode.is_multiplayer_authority():
		hud = hud_scene.instantiate()
		hud.track_cooldown(cooldown_timer)
		playerNode.add_child(hud)
		


func deselect(player : NodePath) -> void:
	var playerNode : WizardPlayer = Engine.get_main_loop().current_scene.get_node(player)
	if playerNode.is_multiplayer_authority():
		if hud:
			hud.visible = false
