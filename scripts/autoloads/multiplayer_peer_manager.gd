extends Node

var peer : ENetMultiplayerPeer

const PORT : int = 7000

func _ready() -> void:
	peer = ENetMultiplayerPeer.new()


func create_server():
	var error = peer.create_server(PORT)
	if error:
		push_error("ERROR WHILE CREATING SERVER: " + str(error))
		return
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_file("res://scenes/levels/main.tscn")
	

func create_client(address : String):
	var error = peer.create_client(address, PORT)
	if error:
		push_error("ERROR WHILE CONNECTING TO SERVER: " + error)
		return
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_file("res://scenes/levels/main.tscn")
	
