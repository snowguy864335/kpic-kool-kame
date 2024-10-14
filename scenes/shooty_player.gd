extends Player
class_name ShootyPlayer
@onready var timer = $Timer
@onready var reloadtimer = $Timer2
@onready var ammoCounter = $UI/RichTextLabel
var ammo := 5
var monkey = preload("res://scenes/monkey.tscn")
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
					var object_spawn = monkey.instantiate()
					object_spawn.global_transform.origin = result["position"]
					get_parent().add_child(object_spawn) #spawning a monkey cause why not and I should learn how anyways
				else:
					print(end)
				if(ammo > 0):
					timer.start(1)
					ammo -= 1
				if(ammo <= 0):
					reloadtimer.start(5)
func _process(delta):
	if(ammo > 0 and timer.is_stopped() == false and reloadtimer.is_stopped()):
		ammoCounter.clear()
		ammoCounter.add_text("Cycling bolt...")
	elif(ammo <= 0 and reloadtimer.is_stopped() == false):
		ammoCounter.clear()
		ammoCounter.add_text("Reloading...")
	elif(timer.is_stopped() and (str(ammoCounter) != "Cycling bolt..." or str(ammoCounter) != "Reloading...") and reloadtimer.is_stopped()):
		ammoCounter.clear()
		ammoCounter.add_text("Ammo: " + str(ammo) + " /5")
	if(ammo <= 0 and timer.is_stopped() and reloadtimer.is_stopped()):
		ammo = 5
