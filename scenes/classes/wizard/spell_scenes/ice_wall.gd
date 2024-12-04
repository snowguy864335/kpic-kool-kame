extends Node3D


func _ready():
	await get_tree().create_timer(10).timeout
	queue_free()
