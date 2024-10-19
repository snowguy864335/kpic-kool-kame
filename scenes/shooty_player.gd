extends Player
class_name ShootyPlayer
const MATH_CONSTANT_PI = 3.141593
@onready var timer = $Timer
@onready var reloadtimer = $Timer2
@onready var ammoCounter = $UI/RichTextLabel
var bulletTrail = preload("res://scenes/bullet_tracer.tscn")
@onready var epic_noise = $AudioStreamPlayer3D
var ammo := 5
func _unhandled_input(event):
	super(event)
	if event is InputEventMouseButton:
		if(timer.is_stopped() and ammo > 0 and reloadtimer.is_stopped()):
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				var space_state = get_world_3d().direct_space_state
				var mousepos = get_viewport().get_mouse_position()
				var origin = camera.project_ray_origin(mousepos)
				var end = origin + camera.project_ray_normal(mousepos) * 1000
				var query = PhysicsRayQueryParameters3D.create(origin, end)
				var result = space_state.intersect_ray(query)
				if(result):
					print(result["position"])
					bullet_trail(result["position"])
				else:
					print(end)
					bullet_trail(end)
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
func bullet_trail(end_point):
	var bullet_trail = bulletTrail.instantiate()
	var direction = (end_point - $bullet_tracer.global_transform.origin).normalized()
	var trail_length : float = ($bullet_tracer.global_transform.origin).distance_to(end_point)
	bullet_trail.position = $bullet_tracer.global_transform.origin + Vector3(0,0,trail_length * 0.5)
	var x_rotation = -atan2(direction.y,sqrt(direction.x * direction.x + direction.z * direction.z))
	var y_rotation = atan2(direction.x,direction.z)
	#IF YOU TOUCH THIS CODE I SWEAR TO GOD(The trig)
	bullet_trail.position = ($bullet_tracer.global_transform.origin + end_point)/2
	bullet_trail.rotation = Vector3(x_rotation,y_rotation,0)
	bullet_trail.scale = Vector3(1,1,trail_length * 20 + 0.05)
	get_parent().add_child(bullet_trail)
	epic_noise.play()
	await get_tree().create_timer(0.25).timeout
	get_parent().remove_child(bullet_trail)
