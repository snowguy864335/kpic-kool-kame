extends RigidBody3D
class_name Grenade

var air_resistance_multiplier : float = 0.94
var is_live : bool = false
const PI : float = 3.14159
var already_kbd_list : Array = []
var explosion = preload("res://scenes/util/explosion.tscn")


func make_live() -> void:
	$time_boom.start()
	$time_boom.connect("timeout", explode)
	is_live = true

func explode() -> void:
	_explode.rpc()


@rpc("any_peer", "call_local")
func _explode():
	if is_live:
		var explosion_but_better = explosion.instantiate()
		explosion_but_better.position = global_position
		add_sibling(explosion_but_better)
		self.is_live = false
		self.visible = false

func _integrate_forces(_state)-> void:
	linear_velocity *= air_resistance_multiplier
