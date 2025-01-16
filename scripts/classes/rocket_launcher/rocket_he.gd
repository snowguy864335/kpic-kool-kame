extends RigidBody3D
var air_resistance_multiplier : float = 0.99 #quite aerodynamic given it's a rocket
var explosion_effect = preload("res://scenes/util/explosion.tscn")
var is_live : bool = true


func _process(delta: float) -> void:
	if($Lifespan.is_stopped() and is_live):
		explode()


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	linear_velocity *= air_resistance_multiplier


func explode() -> void:
	var explosion_effect_but_better = explosion_effect.instantiate()
	explosion_effect_but_better.position = global_position
	explosion_effect_but_better.get_node("Sparks").emitting = true
	explosion_effect_but_better.get_node("Flash").emitting = true
	explosion_effect_but_better.get_node("Fire").emitting = true
	explosion_effect_but_better.get_node("Smoke").emitting = true
	for area in $ExplosionArea.get_overlapping_areas():
		if area is HitboxComponent:
			if area.get_parent().has_method("apply_knockback"):
				var direction = (global_transform.origin - area.global_transform.origin).normalized()
				if(direction.y < 0):
					direction.y += 0.5
				else:
					direction.y -= 0.5
				var knockback : float = -direction/ (area.global_transform.origin.distance_to($ExplosionArea.global_transform.origin)/4 + 0.1)
				area.get_parent().apply_knockback(knockback)
				var damage : int = 6 * ((5- area.global_transform.origin.distance_to($ExplosionArea.global_transform.origin)) + 0.1)
				area.get_parent().hit.rpc(damage)
	self.visible = false
	is_live = false

func super_speed() -> void:
	linear_velocity * 10


func _on_collision_area_body_entered(body: Node3D) -> void:
	if(is_live):
		explode()
