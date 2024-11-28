extends Control

@export_category("Main Menu")
@export var main_scene : PackedScene

func _on_start_button_pressed() -> void:
	if $VBoxContainer/TextEdit.text == "":
		MultiplayerPeerManager.create_client("127.0.0.1")
	else:
		MultiplayerPeerManager.create_client($VBoxContainer/TextEdit.text)


func _on_host_button_pressed() -> void:
	MultiplayerPeerManager.create_server()


func _on_options_pressed() -> void:
	print("Settings pressed")


func _on_quit_game_pressed() -> void:
	get_tree().quit()
