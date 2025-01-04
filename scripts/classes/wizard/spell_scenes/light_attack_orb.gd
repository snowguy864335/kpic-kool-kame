extends Area3D
class_name Fireball

var explosion_scene : PackedScene = preload("res://scenes/util/explosion.tscn")
var exclusion : Array[Node3D] = []

func _physics_process(_delta: float) -> void:
	global_position -= transform.basis.z * 1;
	pass


func _on_collide(body: Node3D) -> void:
	if not body in exclusion:
		var explosion : Node3D = explosion_scene.instantiate()
		explosion.translate(global_position)
		get_parent().add_child(explosion)
		queue_free()
