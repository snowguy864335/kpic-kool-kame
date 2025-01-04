extends MeshInstance3D

@export var color : Color

func _ready():
	material_override = material_override.duplicate(true)

func _process(delta: float) -> void:
	var circle_rotation = rotation_degrees.z
	if circle_rotation < 0:
		circle_rotation = circle_rotation + 360
	color = Color.from_hsv(circle_rotation / 360., 1, 1)
	color.r *= 2.
	color.g *= 2.
	color.b *= 2.
	material_override.set_shader_parameter("color", color)
