extends Node3D

func _ready() -> void:
	set_physics_process(true)
	for child in get_children():
		if child is GPUParticles3D:
			child.emitting = true
	await get_tree().create_timer(1).timeout
	queue_free()

var frame_counter = 0
func _physics_process(_delta: float) -> void:
	launch_bodies()
	frame_counter += 1
	if frame_counter == 2:
		set_physics_process(false)
	

func launch_bodies():
	for area in $Area3D.get_overlapping_areas():
		if area is HitboxComponent:
			var object = area.get_parent()
			if object is CharacterBody3D:
				var direction = (area.global_position + Vector3(0, 1, 0)) - global_position
				var force = (direction) / direction.length_squared()
				force.y = 0.3 / direction.length()
				object.velocity += force * 60
