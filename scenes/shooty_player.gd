extends Player
const MATH_CONSTANT_PI = 3.141593
@onready var timer = $Timer
@onready var reloadtimer = $Timer2
@onready var ammoCounter = $UI/RichTextLabel
var bulletTrail = preload("res://scenes/bullet_tracer.tscn")
@onready var epic_noise = $AudioStreamPlayer3D
var ammo := 5
var bounce_count := 0
func _unhandled_input(event):
	super(event)
	if(Input.is_action_pressed("reload") and reloadtimer.is_stopped() and timer.is_stopped()):
		ammo = 0
		reloadtimer.start(5)
		ammoCounter.clear()
		ammoCounter.add_text("Reloading...")
		await get_tree().create_timer(5.0).timeout
		ammo = 5
		ammoCounter.clear()
		ammoCounter.add_text("Ammo: " + str(ammo) + " /5")
	if event is InputEventMouseButton:
		if(timer.is_stopped() and ammo > 0 and reloadtimer.is_stopped()):
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				cast_ray(false, Vector3(0,0,0),Vector3(0,0,0))
				ammo_counter()
func cast_ray(is_bounce: bool, bounce_origin : Vector3,ricoshot_direction : Vector3) -> void:
	var origin = Vector3(0,0,0)
	var end = Vector3(0,0,0)
	var direction = Vector3(0,0,0)
	var space_state = get_world_3d().direct_space_state
	if(!is_bounce):
		var mousepos = get_viewport().get_mouse_position()
		origin = camera.project_ray_origin(mousepos)
		end = origin + camera.project_ray_normal(mousepos) * 1000
	else:
		origin = bounce_origin + ricoshot_direction * 0.01
		end =  origin + ricoshot_direction * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var result = space_state.intersect_ray(query)
	if(result):
		print(true)
		direction = (end-origin).normalized()
		print(result["position"])
		var normal = result["normal"].normalized()
		if(!is_bounce):
			bullet_trail(result["position"])
		if(is_bounce):
			bullet_trail_bounce(origin,direction,result["position"])
		if(does_it_bounce(direction,normal) and bounce_count <= 3):
			var bounce = direction.bounce(normal)
			cast_ray(true,result["position"],bounce)
	elif(is_bounce):
		bounce_count = 0
		bullet_trail_bounce(origin,ricoshot_direction,end)
	else:
		bounce_count = 0
		bullet_trail(end)
func bullet_trail(end_point): #this function is completely fine don't touch it
	bounce_count = 0
	var bullet_trail = bulletTrail.instantiate()
	var direction = (end_point - $bullet_tracer.global_transform.origin).normalized()
	var trail_length = ($bullet_tracer.global_transform.origin).distance_to(end_point)
	bullet_trail.position = $bullet_tracer.global_transform.origin + Vector3(0,0,trail_length * 0.5)
	bullet_trail.position = ($bullet_tracer.global_transform.origin + end_point)/2
	var x_rotation = -atan2(direction.y,sqrt(direction.x * direction.x + direction.z * direction.z))
	var y_rotation = atan2(direction.x,direction.z)
	#IF YOU TOUCH THIS CODE I SWEAR TO GOD(The trig)
	bullet_trail.rotation = Vector3(x_rotation,y_rotation,0)
	bullet_trail.scale = Vector3(1,1,trail_length * 20 + 0.05)
	get_parent().add_child(bullet_trail)
	epic_noise.play()
	await get_tree().create_timer(0.25).timeout
	get_parent().remove_child(bullet_trail)
func bullet_trail_bounce(start_point,bullet_direction,end_point):
	var bullet_trail = bulletTrail.instantiate()
	var direction = bullet_direction
	var trail_length = (start_point).distance_to(end_point)
	bullet_trail.position = start_point + Vector3(0,0,trail_length * 0.5)
	bullet_trail.position = (start_point + end_point)/2
	var x_rotation = -atan2(direction.y,sqrt(direction.x * direction.x + direction.z * direction.z))
	var y_rotation = atan2(direction.x,direction.z)
	bullet_trail.rotation = Vector3(x_rotation,y_rotation,0)
	bullet_trail.scale = Vector3(1,1,trail_length * 20 + 0.05)
	get_parent().add_child(bullet_trail)
	await get_tree().create_timer(0.25).timeout
	get_parent().remove_child(bullet_trail)
func ammo_counter():
	if(ammo > 1):
		timer.start(1)
		ammo -= 1
		ammoCounter.clear()
		ammoCounter.add_text("Cycling bolt...")
		await get_tree().create_timer(1.0).timeout
		ammoCounter.clear()
		ammoCounter.add_text("Ammo: " + str(ammo) + " /5")
	elif(ammo <= 1):
		reloadtimer.start(5)
		ammoCounter.clear()
		ammoCounter.add_text("Reloading...")
		await get_tree().create_timer(5.0).timeout
		ammo = 5
		ammoCounter.clear()
		ammoCounter.add_text("Ammo: " + str(ammo) + " /5")
func does_it_bounce(direction,normal) -> bool: #temp function, only works for top and bottom of unrotated cubes
	var bounce_angle = (-direction).dot(normal)
	if(bounce_angle <= 0.3 and bounce_count < 3):
		bounce_count += 1
		print("This would've bounced! Bounce count: " + str(bounce_count))
		return true
	bounce_count = 0
	return false
