extends Control

func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		visible = false
