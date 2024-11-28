extends MultiplayerSpawner

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id : int):
	print("Peer connected")
	print(id)

func _on_peer_disconnected(id : int):
	print("Peer disconnected")
	print(id)
