extends Node3D
class_name LightningDashEffect

func play_out(location : Vector3):
	$Out.global_position = location
	$Out.emitting = true

func play_in(location : Vector3):
	$In.global_position = location
	$In.emitting = true
