extends RigidBody3D
class_name Grenade

var air_resistance_multiplier : float = 0.94
var is_live : bool = false
const PI : float = 3.14159
var already_kbd_list : Array = []



func make_live() -> void:
	$time_boom.start()
	is_live = true


func make_die() -> void:
	is_live = false
func _process(delta: float) -> void:
	if($time_boom.is_stopped() and is_live):
		explode()

func explode() -> void:
	for area in $explosion_area.get_overlapping_areas():
		if area is HitboxComponent:
			if area.get_parent().has_method("apply_knockback"):
				var direction = (global_transform.origin - area.global_transform.origin).normalized()
				if(direction.y < 0):
					direction.y += 0.5
				else:
					direction.y -= 0.5
				area.get_parent().apply_knockback(-direction * 1.5 / (area.global_transform.origin.distance_to($explosion_area.global_transform.origin)/5 + 0.1))
				make_die()

func _integrate_forces(PhysicsDirectBodyState3D)-> void:
	linear_velocity *= air_resistance_multiplier
