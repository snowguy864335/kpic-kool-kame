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
	print(str(multiplayer.get_unique_id()) + ": " + str(id))
	var player = load("res://scenes/classes/player.tscn").instantiate()
	add_child(player)
	player.set_multiplayer_authority(id)
	player.name = str(id)
	
