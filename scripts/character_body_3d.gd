extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


@onready var camera := $Camera3D

func _unhandled_input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * 0.01)
			camera.rotate_x(-event.relative.y * 0.01)
			camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

func _physics_process(delta):
	var mouseCoord := get_viewport().get_mouse_position()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor() and Input.is_action_pressed("move_jump"):
		velocity.y += 5
	
	var input_direction : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_direction : Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	velocity += move_direction * 0.8
	velocity.x *= 0.8
	velocity.z *= 0.8

	move_and_slide()
