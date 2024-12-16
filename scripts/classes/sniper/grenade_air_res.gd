extends RigidBody3D
class_name Grenade

var air_resistance_multiplier : float = 0.94
var is_live : bool = false
const PI : float = 3.14159
var already_kbd_list : Array = []
var explosion = preload("res://scenes/util/explosion.tscn")


func make_live() -> void:
	$time_boom.start()
	is_live = true


func _process(delta: float) -> void:
	if($time_boom.is_stopped() and is_live):
		explode()

func explode() -> void:
	if is_live:
		var explosion_but_better = explosion.instantiate()
		explosion_but_better.position = global_position
		add_sibling(explosion_but_better)
		explosion_but_better.get_node("Sparks").emitting = true
		explosion_but_better.get_node("Flash").emitting = true
		explosion_but_better.get_node("Fire").emitting = true
		explosion_but_better.get_node("Smoke").emitting = true
		for area in $explosion_area.get_overlapping_areas():
			if area is HitboxComponent:
				if area.get_parent().has_method("apply_knockback"):
					var direction = (global_transform.origin - area.global_transform.origin).normalized()
					if(direction.y < 0):
						direction.y += 0.5
					else:
						direction.y -= 0.5
					area.get_parent().apply_knockback(-direction * 1.5 / (area.global_transform.origin.distance_to($explosion_area.global_transform.origin)/5 + 0.1))
		self.is_live = false
		self.visible = false

func _integrate_forces(PhysicsDirectBodyState3D)-> void:
	linear_velocity *= air_resistance_multiplier
