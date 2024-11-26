extends Control

@export_category("Main Menu")
@export var main_scene : PackedScene

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/main.tscn")


func _on_options_pressed() -> void:
	print("Settings pressed")


func _on_quit_game_pressed() -> void:
	get_tree().quit()
