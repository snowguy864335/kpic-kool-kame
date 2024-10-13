extends CharacterBody3D

@onready var camera := $Camera3D
@onready var ui := %UI

@export_category("Controller")
@export var speed : float
@export var run_multiplier : float
@export var mouse_sensitivity : float
@export var jump_velocity : float
@export var ground_friction_multiplier : float
@export var air_resistance_multiplier : float
@export var air_movement_modifier : float
@export var fov := 75



func _unhandled_input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y( (-event.relative.x * 0.01) * mouse_sensitivity)
			camera.rotate_x( (-event.relative.y * 0.01) * mouse_sensitivity)
			camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

var prev_pos : Vector3
var run_time_elapsed := 0.0
func _physics_process(delta):
	var mouseCoord := get_viewport().get_mouse_position()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor() and Input.is_action_pressed("move_jump"):
		velocity.y += jump_velocity
	
	var input_direction : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	var move_direction : Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	var movement_multiplier = speed
	if (Input.is_action_pressed("move_run")):
		run_time_elapsed = min(run_time_elapsed + delta, 0.5)
		movement_multiplier *= run_multiplier
	else:
		run_time_elapsed = max(run_time_elapsed - delta, 0)
	if not is_on_floor():
		movement_multiplier *= air_movement_modifier
	camera.fov = lerpf(fov, fov * run_multiplier, clamp(0, 1, run_time_elapsed * 2)) as int
	
	
	
	velocity += move_direction * speed * movement_multiplier
	if is_on_floor():
		velocity.x *= ground_friction_multiplier
		velocity.z *= ground_friction_multiplier
	else:
		velocity.x *= air_resistance_multiplier
		velocity.z *= air_resistance_multiplier
	prev_pos = position
	ui.set_property("Velocity", str(velocity.length()))
	

func _process(delta):
	if Input.is_action_just_pressed("debug"):
		if ui.is_debug_visible():
			ui.hide_debug()
		else:
			ui.show_debug()


	move_and_slide()
