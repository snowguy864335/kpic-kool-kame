extends Area3D
class_name HitboxComponent

signal onHit(amount : int)

@export_category("Hitbox")
@export var healthComponent : HealthComponent

func hit(damage : int) -> void:
	onHit.emit(damage)
	if (healthComponent):
		healthComponent.changeHealth(-damage);
