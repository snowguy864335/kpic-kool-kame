extends Player
const MATH_CONSTANT_PI = 3.141593
@onready var timer = $Timer
@onready var reloadtimer = $Timer2
@onready var ammoCounter = $UI/RichTextLabel
var bulletTrail = preload("res://scenes/bullet_tracer.tscn")
@onready var epic_noise = $AudioStreamPlayer3D
@onready var weapon = $Player_weapon
var ammo : int = 5
var bounce_count : int = 0
var penetration_depth := 0.2
var exclusion_list : Array = []


func _unhandled_input(event):
	exclusion_list = []
	super(event)
	#if event is InputEventMouseMotion: Weapon rotation with camera rotation to be implemented later
		#weapon.rotate_x( (-event.relative.y * 0.01) * mouse_sensitivity)
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
				penetration_depth = 0.2
				cast_ray(false, Vector3(0,0,0),Vector3(0,0,0), exclusion_list)
				ammo_counter()


func cast_ray(is_bounce: bool, bounce_origin : Vector3,ricoshot_direction : Vector3, exlusion_list : Array) -> void:
	var origin : Vector3 = Vector3(0,0,0)
	var end : Vector3 = Vector3(0,0,0)
	var direction : Vector3 = Vector3(0,0,0)
	var space_state = get_world_3d().direct_space_state
	
	if(!is_bounce and ricoshot_direction.is_equal_approx(Vector3(0,0,0))):
		var mousepos = get_viewport().get_mouse_position()
		origin = camera.project_ray_origin(mousepos)
		end = origin + camera.project_ray_normal(mousepos) * 1000
	else:
		origin = bounce_origin + ricoshot_direction * 0.01
		end =  origin + ricoshot_direction * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = exclusion_list
	var result = space_state.intersect_ray(query)
	if(result):
		direction = (end-origin).normalized()
		var normal = result["normal"].normalized()
		
		if(!is_bounce):
			BulletTrailManager.create_bullet_trail(origin, result["position"], camera.global_basis.z, 0.02)
		
		if(is_bounce):
			BulletTrailManager.create_bullet_trail(origin, result["position"], camera.global_basis.z, 0.02)
		
		if(does_it_bounce(direction, normal) and bounce_count <= 3):
			var bounce = direction.bounce(normal)
			cast_ray(true,result["position"],bounce, exclusion_list)
		else:
			does_it_penetrate(result["position"],direction,result["collider"])
	
	elif(is_bounce):
		bounce_count = 0
		BulletTrailManager.create_bullet_trail(origin, end, direction, 0.02)
		penetration_depth = 0.2
	else:
		bounce_count = 0
		BulletTrailManager.create_bullet_trail(origin, end, direction, 0.02)
		penetration_depth = 0.2


#Any commented awaits in a bullet trail function are there for testing purposes
func bullet_trail(end_point : Vector3) -> void: #this function is completely fine don't touch it
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
	#await get_tree().create_timer(2.5).timeout
	get_parent().remove_child(bullet_trail)


func bullet_trail_bounce(start_point : Vector3,bullet_direction : Vector3,end_point : Vector3) -> void:
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
	#await get_tree().create_timer(2.5).timeout
	get_parent().remove_child(bullet_trail)


func ammo_counter() -> void:
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


func does_it_bounce(direction : Vector3,normal : Vector3) -> bool:
	var bounce_angle = (-direction).dot(normal)
	if(bounce_angle <= 0.3 and bounce_count < 3):
		bounce_count += 1
		return true
		penetration_depth *= 0.8
	bounce_count = 0
	return false


func does_it_penetrate(origin : Vector3,direction : Vector3, object : Object) -> void:
	exclusion_list.append(object)
	var penetration_check_end_point : Vector3 = origin + direction * penetration_depth
	var query = PhysicsPointQueryParameters3D.new()
	query.position = penetration_check_end_point
	var penetration_space_state := get_world_3d().direct_space_state
	var penetration_check_info := penetration_space_state.intersect_point(query,1)
	if(penetration_check_info.is_empty()):
		var i : int = 20
		while(i >= 0):
			query.position = origin + direction * (penetration_depth / i)
			penetration_check_info = penetration_space_state.intersect_point(query,1)
			if(penetration_check_info.is_empty()):
				cast_ray(true,origin + direction * 0.01,direction, exclusion_list)
				penetration_depth = penetration_depth - penetration_depth / i
				break
			i = i -1
			
	else:
		penetration_depth = 0.2
