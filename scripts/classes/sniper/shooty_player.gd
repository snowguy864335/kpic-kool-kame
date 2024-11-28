extends Player
const MATH_CONSTANT_PI = 3.141593
@onready var timer = $Timer
@onready var reloadtimer = $Timer2
@onready var ammoCounter = $UI/RichTextLabel
@onready var epic_noise = $AudioStreamPlayer3D
@onready var weapon = $Player_weapon

var ammo : int = 5
var bounce_count : int = 0
var penetration_depth := 0.2
var exclusion_list : Array = []

func _unhandled_input(event):
	exclusion_list = []
	super(event)
	if !is_multiplayer_authority():
		return
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


func cast_ray(is_bounce: bool, bounce_origin : Vector3, 
ricoshot_direction : Vector3, exclusion_list : Array, start_length : float = 0) -> void:
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
	query.collide_with_bodies = true
	query.collide_with_areas = true
	query.exclude.append(collisionbox.shape.get_rid())
	query.exclude.append(hurtbox.shape.get_rid())
	var result = space_state.intersect_ray(query)
	if(result):
		var damage_query = PhysicsShapeQueryParameters3D.new();
		var shape = SphereShape3D.new()
		shape.radius = 0.01
		damage_query.shape = shape
		damage_query.transform = damage_query.transform.translated(result["position"])
		
		damage_query.collide_with_areas = true
		damage_query.collide_with_bodies = true
		var damage_result = space_state.intersect_shape(damage_query)
		for collision in damage_result:
			if (collision["collider"] is HitboxComponent):
				collision["collider"].hit(10)
			
		
		direction = (end-origin).normalized()
		var normal = result["normal"].normalized()
		
		if(!is_bounce):
			BulletTrailManager.create_bullet_trail.rpc(origin, result["position"], camera.global_basis.z, 0.02, start_length)
		
		if(is_bounce):
			BulletTrailManager.create_bullet_trail.rpc(origin, result["position"], camera.global_basis.z, 0.02, start_length)

		if(does_it_bounce(direction, normal) and bounce_count <= 3):
			
			var bounce = direction.bounce(normal)
			cast_ray(true,result["position"],bounce, exclusion_list, start_length + (result["position"] - origin).length() * 100)
		else:
			does_it_penetrate(result["position"],direction,result["collider"])
	
	elif(is_bounce):
		bounce_count = 0
		BulletTrailManager.create_bullet_trail.rpc(origin, end, direction, 0.02, start_length)
		penetration_depth = 0.2
	else:
		bounce_count = 0
		BulletTrailManager.create_bullet_trail.rpc(origin, end, direction, 0.02, start_length)
		penetration_depth = 0.2

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
		penetration_depth *= 0.8
		return true
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
