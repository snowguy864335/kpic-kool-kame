extends Area3D


func _on_area_entered(area: Area3D) -> void:
	if area is HitboxComponent:
		if area.get_parent().has_method("apply_knockback"):
			area.get_parent().apply_knockback(Vector3(0, 3, 0))
