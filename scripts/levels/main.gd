extends Node3D

func _ready() -> void:
	multiplayer.peer_connected.connect(_add_player)
	_add_player(multiplayer.get_unique_id())

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _add_player(id : int):
	print_rich(
		"[NETWORK] [color=green]A peer numbered "
		 + str(multiplayer.get_unique_id()) + " has connected to " + str(id) + "[/color]")
	var player : Player = load("res://scenes/classes/sniper/shooty_player.tscn").instantiate()
	player.position = $PlayerSpawnpoint.global_position
	add_child(player)
	player.set_multiplayer_authority(id)
	player.name = str(id)
	
