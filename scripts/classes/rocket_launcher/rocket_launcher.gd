extends Player
var energy : int = 100
var ammo_types : Array = ["HE","AP","HEAT"] #Used for UI
var type_selected : int = 1 #Next rocket to be loaded
var currently_loaded_type : int = 1 #Currently loaded shell
var total_delta : float = 0
var skill_two_held : float = 0
var rocket_HE = preload("res://scenes/classes/rocket launcher/rocket_he.tscn")
var rocket_AP  = preload("res://scenes/classes/rocket launcher/rocket_he.tscn") #temp
var rocket_HEAT  = preload("res://scenes/classes/rocket launcher/rocket_he.tscn") #temp
var rocket_ALHVAS = preload("res://scenes/classes/rocket launcher/rocket_he.tscn") #temp, only activates of 1k damage dealt
var ammo_array : Array = [rocket_HE,rocket_AP,rocket_HEAT] #used to not need 3 if statements
var super_shot_sequence : Array = [3,1,2]
var super_shot_temp : Array = [0,0,0]
signal super_speed #tells the projectile to go forth and win your war


func _physics_process(delta: float) -> void:
	super(delta)
	if(Input.is_action_just_pressed("skill_one") and $SkillOneCd.is_stopped() and energy >= 40):
		velocity.y = -60 * sin(camera.global_rotation.x)
		velocity.x = -60 * -sin(global_rotation.y)
		velocity.z = -60 * -sin(global_rotation.y + PI/2)
		skill_one()
		#how the hell do I code something that reverses projectiles lmao, I guess area3d
		#I guess, when area entered, if area "projectile", area.linear_velocity * -2
	if(!is_on_floor() and !$SkillOneMomentum.is_stopped()):
		air_resistance_multiplier = 0.99
	else:
		air_resistance_multiplier = 0.94


func _process(delta: float) -> void:
	if($RechargeTimer.is_stopped() and energy < 100 and total_delta > 0.035):
		energy += 1
		total_delta = 0
	else:
		total_delta += delta
	if(skill_two_held >= 1.5 and Input.is_action_just_released("skill_two") and $ShotCd.is_stopped()):
		skill_two_eject()
	elif(Input.is_action_just_released("skill_two") and skill_two_held < 1.5):
		type_selected += 1
		if(type_selected >= 4):
			type_selected = 1
	if(Input.is_action_pressed("skill_two") and $SkillTwoCd.is_stopped()):
		skill_two_held += delta
	else:
		skill_two_held = 0
	energy_counter() #updates ui at the end of every frame


func _unhandled_input(event: InputEvent) -> void:
	super(event)
	if(Input.is_action_just_pressed("attack") and $ShotCd.is_stopped() and energy >= 20):
		fire_rocket()
	if(energy < 0):
		energy = 0


func fire_rocket() -> void:
	$ShotCd.start()
	$RechargeTimer.start()
	energy -= 20
	var rocket_to_be_spawned = ammo_array[currently_loaded_type].instantiate()
	rocket_to_be_spawned.linear_velocity.y = 200 * sin(camera.global_rotation.x) + velocity.x
	rocket_to_be_spawned.linear_velocity.x = 200 * -sin(global_rotation.y) + velocity.y
	rocket_to_be_spawned.linear_velocity.z = 200 * -sin(global_rotation.y + PI/2) + velocity.z
	rocket_to_be_spawned =  $Camera3D.global_transform
	rocket_to_be_spawned.position = $RocketSpawn.global_position
	rocket_to_be_spawned.rotation.x = $Camera3D.global_rotation.x
	super_speed.connect(rocket_to_be_spawned)
	add_sibling(rocket_to_be_spawned)
	await get_tree().create_timer(5).timeout
	rocket_to_be_spawned.queue_free()
	currently_loaded_type = type_selected #keep this at the end


func skill_one() -> void: #this is only for the launching projectiles away part
	$RechargeTimer.start()
	$SkillOneCd.start()
	#make it apply kb to players instead of reversing direction


func skill_two_eject() -> void: #ejects the shell is basically fire rocket but far slower
	$RechargeTimer.start()
	$SkillTwoCd.start()
	currently_loaded_type = type_selected #keep this at the end

func energy_counter() -> void: #this script literally just edits the ammo UI
	if(energy < 0):
		energy = 0


func ammo_type_display() -> void: #this script literally just edits the ammo UI too
	pass
