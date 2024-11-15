extends MeshInstance3D
class_name BulletTracer

var shader_mat : ShaderMaterial = preload("res://assets/materials/bullet_trail.tres")

var start_time : float

func set_length(len : float) -> void:
	assert(mesh is QuadMesh)
	var quad_mesh := mesh as QuadMesh
	
	assert(quad_mesh.material is ShaderMaterial)
	var shader := quad_mesh.material as ShaderMaterial
	
	shader.set_shader_parameter("line_length", len)
	


func set_axis(axis : Vector3) -> void:
	assert(mesh is QuadMesh)
	var quad_mesh := mesh as QuadMesh
	
	assert(quad_mesh.material is ShaderMaterial)
	var shader := quad_mesh.material as ShaderMaterial
	
	shader.set_shader_parameter("default_axis", axis)


func set_width(width : float) -> void:
	assert(mesh is QuadMesh)
	var quad_mesh := mesh as QuadMesh
	
	assert(quad_mesh.material is ShaderMaterial)
	var shader := quad_mesh.material as ShaderMaterial
	
	shader.set_shader_parameter("line_width", width)


func _init() -> void:
	start_time = Time.get_ticks_msec()
	mesh = QuadMesh.new()
	mesh.material = shader_mat.duplicate(true)


func _process(delta: float) -> void:
	assert(mesh is QuadMesh)
	var quad_mesh := mesh as QuadMesh
	
	assert(quad_mesh.material is ShaderMaterial)
	var shader := quad_mesh.material as ShaderMaterial
	var time = Time.get_ticks_msec()
	shader.set_shader_parameter("animation_time", time - start_time)
