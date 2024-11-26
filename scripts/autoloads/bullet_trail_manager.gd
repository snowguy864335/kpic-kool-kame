extends Node


@export var scene : PackedScene = preload("res://scenes/classes/sniper/bullet_tracer.tscn")
@export var shader : ShaderMaterial = preload("res://assets/materials/bullet_trail.tres")

func create_bullet_trail(start: Vector3, end: Vector3, direction: Vector3, width: float, delay: float = 0) -> MeshInstance3D:
	var mesh := scene.instantiate()
	
	mesh.custom_aabb = AABB(Vector3(-10000, -10000, -10000), Vector3(20000, 20000, 20000))
	
	direction = -(end-start).normalized()
	
	mesh.set_axis(-direction)
	mesh.set_length(abs((end-start).length()))
	mesh.set_width(width)
	mesh.set_delay(delay)
	mesh.set_mask_fade_speed(1. / 3000.)
	mesh.set_animation_speed(10)
	
	mesh.transform.origin = start
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	
	add_child(mesh)
	return mesh
	
