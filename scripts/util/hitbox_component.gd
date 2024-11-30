extends Area3D
class_name HitboxComponent

signal onHit(amount : int)

@export_category("Hitbox")
@export var healthComponent : HealthComponent

@rpc("any_peer", "call_local")
func hit(damage : int, bypassOneShotProtection : bool = false) -> void:
	onHit.emit(damage)
	if (healthComponent):
		if (healthComponent.health >= healthComponent.maxHealth
		 and healthComponent.health - damage < 0
		 and not bypassOneShotProtection):
			healthComponent.setHealth(1, true)
		else:
			healthComponent.changeHealth(-damage)
