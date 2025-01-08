extends RigidBody3D
var air_resistance_multiplier : float = 0.96 #slightly more aerodyanmic given it is a rocket
var explosion_effect = preload("res://scenes/util/explosion.tscn")
#var previous_position : Vector3


#uncomment func ready for when interpolation is ready to be added, as well as _physics_processes
#func _ready() -> void:
	#previous_position = global_position


func _process(delta: float) -> void:
	if($Lifespan.is_stopped()):
		explode()


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	linear_velocity *= air_resistance_multiplier


func explode() -> void:
	pass


func super_speed() -> void:
	linear_velocity * 10


#func _physics_process(delta: float) -> void:
	#pass
