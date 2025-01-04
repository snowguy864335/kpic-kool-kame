extends Node3D
class_name LightningAttackScene

func _ready() -> void:
	get_tree().create_timer(1).timeout.connect(func(): queue_free())
