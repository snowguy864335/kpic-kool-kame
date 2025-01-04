extends Node3D

const player_types = {
	"Sniper": preload("res://scenes/classes/sniper/shooty_player.tscn"),
	"Wizard": preload("res://scenes/classes/wizard/wizard_player.tscn")
}

func _ready() -> void:
	MultiplayerPeerManager.added_player.connect(register_player)
	var player = MultiplayerPeerManager.personal_player_info
	_add_player(multiplayer.get_unique_id(), player["name"], player["type"])

func register_player(id : int) -> void:
	var peers = MultiplayerPeerManager.other_player_info
	var new_player = peers[id]
	_add_player(id, new_player["name"], new_player["type"])
	

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _add_player(id : int, p_name : String, type : String):
	print_rich(
		"[NETWORK] [color=green]A peer numbered "
		 + str(multiplayer.get_unique_id()) + " has connected to " + str(id) + "[/color]")
	var player_scene : PackedScene = player_types[type]
	var player : Player = player_scene.instantiate()
	player.position = $PlayerSpawnpoint.global_position
	add_child(player)
	player.set_multiplayer_authority(id)
	player.name = p_name
	player.client_setup.rpc_id(id)
