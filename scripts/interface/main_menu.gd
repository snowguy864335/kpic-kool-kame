extends Control

@export_category("Main Menu")
@export var main_scene : PackedScene

func _on_start_button_pressed() -> void:
	var username = $VBoxContainer/Username.text
	var type = $VBoxContainer/ClassSelect.text
	MultiplayerPeerManager.set_info(username, type)
	if $VBoxContainer/TextEdit.text == "":
		MultiplayerPeerManager.create_client("127.0.0.1")
	else:
		MultiplayerPeerManager.create_client($VBoxContainer/TextEdit.text)


func _on_host_button_pressed() -> void:
	var username = $VBoxContainer/Username.text
	var type = $VBoxContainer/ClassSelect.text
	MultiplayerPeerManager.set_info(username, type)
	MultiplayerPeerManager.create_server()


func _on_options_pressed() -> void:
	print("Settings pressed")


func _on_quit_game_pressed() -> void:
	get_tree().quit()
