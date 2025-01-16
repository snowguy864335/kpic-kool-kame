extends Player
const MATH_CONSTANT_PI = 3.141593

signal explode

@onready var timer = $Timer
@onready var reloadtimer = $Timer2
@onready var ammoCounter = $UI/RichTextLabel
@onready var epic_noise = $AudioStreamPlayer3D
@onready var weapon = $Player_weapon
@onready var skill_one_timer = $skill_one_timer
@onready var skill_two_timer = $skill_two_timer
@onready var skill_two_momentum = $skill_two_momentum
var ammo : int = 5
var grenade = preload("res://scenes/classes/sniper/sniper_grenade.tscn")
var explosion = preload("res://scenes/util/explosion.tscn")
var bounce_count : int = 0
var penetration_depth : float = 0.2
var exclusion_list : Array = []


func _physics_process(delta: float) -> void:
	super(delta)
	if (Input.is_action_pressed("skill_two") and skill_two_timer.is_stopped()):
		skill_two_timer.start()
		velocity.y = 70 * sin(camera.global_rotation.x)
		velocity.x = 70 * -sin(global_rotation.y)
		velocity.z = 70 * -sin(global_rotation.y + MATH_CONSTANT_PI/2)
		skill_two_momentum.start()
	if  (!is_on_floor() and !skill_two_momentum.is_stopped()):
		air_resistance_multiplier = 0.99
	else:
		air_resistance_multiplier = 0.94
	
func _unhandled_input(event):
	exclusion_list = []
	super(event)
	if !is_multiplayer_authority():
		return
	#if event is InputEventMouseMotion: to be implemented later
		#weapon.rotation.z = -camera.global_rotation.x
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
				cast_ray(false, Vector3(0,0,0),Vector3(0,0,0))
				ammo_counter()
	if(Input.is_action_just_released("skill_one") and skill_one_timer.is_stopped()):
		var grenade_but_cool : Grenade = grenade.instantiate()
		var explosion_but_better = explosion.instantiate()
		skill_one_timer.start()
		explode.connect(grenade_but_cool.explode)
		grenade_but_cool.transform = $Camera3D.global_transform
		grenade_but_cool.position = $grenade_spawn.global_position
		grenade_but_cool.rotation.x = camera.rotation.x + MATH_CONSTANT_PI/2
		grenade_but_cool.linear_velocity.y = 50 * sin(camera.global_rotation.x) + velocity.x
		grenade_but_cool.linear_velocity.x = 50 * -sin(global_rotation.y) + velocity.y
		grenade_but_cool.linear_velocity.z = 50 * -sin(global_rotation.y + MATH_CONSTANT_PI/2) + velocity.z
		add_sibling(grenade_but_cool)
		grenade_but_cool.make_live()
		await get_tree().create_timer(4).timeout
		explosion_but_better.queue_free()
	if(Input.is_action_just_released("skill_one") and !skill_one_timer.is_stopped()):
		emit_signal("explode")


func cast_ray(is_bounce: bool, bounce_origin : Vector3, 
ricoshot_direction : Vector3, start_length : float = 0) -> void:
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
		var shape = CylinderShape3D.new()
		var h = 0.2
		var r = 0.02
		shape.height = h
		shape.radius = r
		damage_query.shape = shape
		damage_query.transform = damage_query.transform.translated(result["position"])
		damage_query.transform.basis.y = result["normal"]
		damage_query.transform.basis.z = damage_query.transform.basis.y.cross(Vector3.UP)
		if damage_query.transform.basis.z == Vector3.ZERO:
			damage_query.transform.basis.z = damage_query.transform.basis.y.cross(Vector3.LEFT)
		damage_query.transform.basis.x = damage_query.transform.basis.y.cross(damage_query.transform.basis.z)
		damage_query.transform = damage_query.transform.translated(-damage_query.transform.basis.y * h / 2.)
		
		damage_query.collide_with_areas = true
		damage_query.collide_with_bodies = true
		damage_query.exclude.append(collisionbox.shape.get_rid())
		damage_query.exclude.append(hurtbox.shape.get_rid())
		# Uncomment to preview the damage query shape
		#var mesh_preview = MeshInstance3D.new()
		#mesh_preview.global_transform = damage_query.transform
		#var mesh = CylinderMesh.new()
		#mesh.height = h
		#mesh.top_radius = r
		#mesh.bottom_radius = r
		#mesh_preview.mesh = mesh
		#get_parent().add_child(mesh_preview)
		var damage_result = space_state.intersect_shape(damage_query)
		for collision in damage_result:
			if (collision["collider"] is HitboxComponent):
				collision["collider"].hit.rpc(10)
			
		
		direction = (end-origin).normalized()
		var normal = result["normal"].normalized()
		
		if(!is_bounce):
			BulletTrailManager.create_bullet_trail.rpc(origin, result["position"], camera.global_basis.z, 0.02, start_length)
		
		if(is_bounce):
			BulletTrailManager.create_bullet_trail.rpc(origin, result["position"], camera.global_basis.z, 0.02, start_length)

		if(does_it_bounce(direction, normal) and bounce_count <= 3):
			
			var bounce = direction.bounce(normal)
			cast_ray(true,result["position"],bounce, start_length + (result["position"] - origin).length() * 100)
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
				cast_ray(true,origin + direction * 0.01,direction)
				penetration_depth = penetration_depth - penetration_depth / i
				break
			i = i -1
			
	else:
		penetration_depth = 0.2
