extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
func _physics_process(delta):
	var forwardMovement = Vector3.FORWARD

		
func _input(event):	
	if event is InputEventMouseMotion:
		rotate_object_local(Vector3.DOWN, event.relative.x * 0.005)
	
func movement():
	pass
