extends Control

func _process(_delta: float) -> void:
	if !is_multiplayer_authority():
		visible = false
