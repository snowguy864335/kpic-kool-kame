extends Node

var peer : ENetMultiplayerPeer

const PORT : int = 7000

var personal_player_info = {}
var other_player_info = {}

signal added_player(id)

func set_info(name : String, type : String) -> void:
	personal_player_info["name"] = name
	personal_player_info["type"] = type


func _ready() -> void:
	peer = ENetMultiplayerPeer.new()
	multiplayer.peer_connected.connect(_on_join)
	

func create_server():
	print_rich("[NETWORK] [color=yellow]Attempting to create a server on port " + str(PORT))
	var error = peer.create_server(PORT)
	if error:
		push_error()
		push_error("ERROR WHILE CREATING SERVER: " + str(error))
		return
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_file("res://scenes/levels/main.tscn")
	

func create_client(address : String):
	print_rich("[NETWORK] [color=yellow]Attempting to connect to a server on address " + address + ":" + str(PORT))
	var error = peer.create_client(address, PORT)
	if error:
		push_error("ERROR WHILE CONNECTING TO SERVER: " + error)
		return
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_file("res://scenes/levels/main.tscn")
	

func _on_join(id):
	print("Player joining")
	_receive_player.rpc_id(id, multiplayer.get_unique_id(), personal_player_info)


@rpc("any_peer", "call_local")
func _receive_player(id, info : Dictionary):
	print("Receiving player")
	assert(info.has("name") and info.has("type"))
	other_player_info[id] = {"name": info["name"], "type": info["type"]}
	added_player.emit(id)
