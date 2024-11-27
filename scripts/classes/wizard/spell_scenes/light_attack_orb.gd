extends Area3D

func _physics_process(delta: float) -> void:
	global_position -= transform.basis.z * 2;
	pass
