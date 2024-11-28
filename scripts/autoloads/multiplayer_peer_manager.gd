extends Node

var peer : ENetMultiplayerPeer

const PORT : int = 7000

func _ready() -> void:
	peer = ENetMultiplayerPeer.new()


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
	
