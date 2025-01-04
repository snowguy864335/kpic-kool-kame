extends Node3D
class_name HealEffect

func play(location : Vector3):
	$Effect.global_position = location
	$Effect.emitting = true
