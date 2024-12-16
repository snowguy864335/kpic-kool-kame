extends Player
class_name RangedBaseClass
@export var max_health : int #wow I bet you can't guess what this does, it's max health
@export var current_health: int #real tough one, it's the current health
@onready var timer : Timer #timer to use for between shots
var intermitent_shot_cd : float #time between shots
@onready var reload_timer : Timer #timer used for reloading
var time_to_reload : float #time it takes to reload
var time_to_vanish : float #how long you want it to take for a trail to disappear
@onready var ammo_counter : RichTextLabel #The ammo counter at the bottom right
var bulletTrail = preload("res://scenes/bullet_tracer.tscn") #loads bullet trail
@onready var projectile : Node3D #whatever projectile you need for m1
var projectile_exclusion_list : Array #the list to exclude from projectile collision
@onready var gunshot_noise : AudioStreamPlayer3D #the noise you want to play on shot
@onready var weapon : Object #the player weapon model
@onready var hitbox : Area3D #the player hitbox, duh
var max_ammo : int #the max ammo, set to 100 if energy class
var ammo : int #the ammo, set to 100 if energy class, set to max by default
var bounce_count_max : int #how many times a projectile can bounce if it can
var bounce_count : int #how many times it has bounced
var bounce_angle : float #the angle at which you want a bounce to trigger
var penetration_depth_max : float #how deep you want a projectile to be at max able to penetrate
var penetration_depth : float #how deep you want a projectile to be able to penetrate
var penetration_decay_bounce : float #how much you want a projectile to lose penetration by upon bounce
@export var exclusion_list : Array = [] #put all objects you want excluded froma raycast here at start of unhandled input
var is_energy_class : bool #set ammo to 100 if true
var is_projectile_class : bool #true if this class does not utilize hitscan
var skill_one_cost : int #ammo requirement for skill one if needed
var skill_two_cost : int #ammo requirement for skill two if needed
var ammo_type : String #just whatever you want displayed next to the ammo count
var bullet_trail_scale : Vector3 #how you want the trail scaled, keep z at one please
var projectile_velocity : float #whatever you want the speed of your projectile to be if used


func _unhandled_input(event) -> void:
	exclusion_list = []
	super(event)
	if(can_reload()):
		reload()
	if event is InputEventMouseButton:
		if(can_fire(event)):
			penetration_depth = penetration_depth_max
			cast_ray(false, Vector3(0,0,0),Vector3(0,0,0))
			ammo_counter_func()
func can_reload() -> bool:
	if(Input.is_action_pressed("reload") and reload_timer.is_stopped() and timer.is_stopped() and !is_energy_class):
		return true
	return false


func reload() -> void:
	ammo = 0
	reload_timer.start(time_to_reload)
	ammo_counter.clear()
	ammo_counter.add_text("Reloading...")
	await get_tree().create_timer(time_to_reload).timeout
	ammo = max_ammo
	ammo_counter.clear()
	ammo_counter.add_text(ammo_type + ": " + str(ammo) + " /" + str(max_ammo))


func can_fire(event) -> bool:
	if(timer.is_stopped() and ammo > 0 and reload_timer.is_stopped()): #will add input map for m1 later
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			return true
	return false


func cast_ray(is_bounce : bool, bounce_origin : Vector3, ricoshot_direction : Vector3) -> void:
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
				bullet_trail(result["position"])
		if(is_bounce):
			bullet_trail_bounce(origin,direction,result["position"])
		if(does_it_bounce(direction,normal) and bounce_count <= bounce_count_max):
			var bounce = direction.bounce(normal)
			cast_ray(true,result["position"],bounce)
		else:
			does_it_penetrate(result["position"],direction,result["collider"])
	elif(is_bounce):
		bounce_count = 0
		bullet_trail_bounce(origin,ricoshot_direction,end)
		penetration_depth = penetration_depth_max
	else:
		bounce_count = 0
		bullet_trail(end)
		penetration_depth = penetration_depth_max
#This function casts the ray for various purposes and is recursive


func bullet_trail(end_point: Vector3) -> void:
	bounce_count = 0
	var bullet_trail = bulletTrail.instantiate()
	var direction = (end_point - $bullet_tracer.global_transform.origin).normalized()
	var trail_length = ($bullet_tracer.global_transform.origin).distance_to(end_point)
	bullet_trail.position = $bullet_tracer.global_transform.origin + Vector3(0,0,trail_length * 0.5)
	bullet_trail.position = ($bullet_tracer.global_transform.origin + end_point)/2
	var x_rotation = -atan2(direction.y,sqrt(direction.x * direction.x + direction.z * direction.z))
	var y_rotation = atan2(direction.x,direction.z)
	bullet_trail.rotation = Vector3(x_rotation,y_rotation,0)
	bullet_trail.scale = Vector3(1,1,trail_length * 20 + 0.05)
	gunshot_noise.play()
	if(!is_projectile_class): #really hoping that something like this conditional doesn't cause memory leaks
		get_parent().add_child(bullet_trail)
		await get_tree().create_timer(time_to_vanish).timeout
		get_parent().remove_child(bullet_trail)
#Instantiates the bullet trail scene which is used for damage.


func bullet_trail_bounce(start_point : Vector3, bullet_direction : Vector3, end_point : Vector3) -> void:
	var bullet_trail = bulletTrail.instantiate()
	var direction = bullet_direction
	var trail_length = (start_point).distance_to(end_point)
	bullet_trail.position = start_point + Vector3(0,0,trail_length * 0.5)
	bullet_trail.position = (start_point + end_point)/2
	var x_rotation = -atan2(direction.y,sqrt(direction.x * direction.x + direction.z * direction.z))
	var y_rotation = atan2(direction.x,direction.z)
	bullet_trail.rotation = Vector3(x_rotation,y_rotation,0)
	bullet_trail.scale = Vector3(1,1,trail_length * 20 + 0.05)
	if(!is_projectile_class):
		get_parent().add_child(bullet_trail)
		await get_tree().create_timer(time_to_vanish).timeout
		get_parent().remove_child(bullet_trail)
	else:
		var projectile_rotation : Vector3 = bullet_trail.rotation
		spawn_projectile(projectile_rotation)
#Instantiates a bullet trail but with more parameters


func does_it_bounce(direction : Vector3,normal : Vector3) -> bool: 
	var collision_angle : float = (-direction).dot(normal)
	if(collision_angle <= bounce_angle and bounce_count < bounce_count_max):
		bounce_count += 1
		return true
		penetration_depth *= 0.8
	bounce_count = 0
	return false
#Checks if the bullet needs to bounce


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
				projectile_exclusion_list.append(object)
				break
			i = i -1
			
	else:
		penetration_depth = penetration_depth_max
#Creates an additional raycast if it can penetrate

func ammo_counter_func() -> void:
	if(ammo > 1):
		timer.start(intermitent_shot_cd)
		ammo -= 1
		ammo_counter.clear()
		await get_tree().create_timer(intermitent_shot_cd).timeout
		ammo_counter.clear()
		ammo_counter.add_text(ammo_type + ": " + str(ammo) + "/" + str(max_ammo))
	elif(ammo <= 1 and !is_energy_class):
		reload_timer.start(time_to_reload)
		ammo_counter.clear()
		ammo_counter.add_text("Reloading...")
		await get_tree().create_timer(5.0).timeout
		ammo = max_ammo
		ammo_counter.clear()
		ammo_counter.add_text(ammo_type + ": " + str(ammo) + "/" + str(max_ammo))

func spawn_projectile(projectile_rotation : Vector3) -> void:
	var projectile_to_spawn = projectile.instantiate()
	projectile_to_spawn.rotation = projectile_rotation
	projectile_to_spawn.velocity.x = projectile_velocity * sin(projectile_rotation.y)
	projectile_to_spawn.velocity.z = projectile_velocity * sin(projectile_rotation.y) # + pi/2
	projectile_to_spawn.velocity.y = projectile_velocity * sin(-projectile_rotation.x)
