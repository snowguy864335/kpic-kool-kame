extends MeshInstance3D
class_name BulletTracer

var bullet_trail_shader_material : ShaderMaterial = preload("res://assets/materials/bullet_trail.tres")
var bullet_trail_shader_mask_texture : Texture2D = preload("res://assets/textures/bullet_trail_mask.tres")

var speed : float = 0

var start_time : float = 0
var delay : float = 0

func set_length(new_len : float) -> void:
	assert(mesh is QuadMesh)
	var quad_mesh := mesh as QuadMesh
	
	assert(quad_mesh.material is ShaderMaterial)
	var shader := quad_mesh.material as ShaderMaterial
	
	shader.set_shader_parameter("line_length", new_len)
	shader.set_shader_parameter("mask", bullet_trail_shader_mask_texture)
	


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

func set_delay(new_delay: float) -> void:
	self.delay = new_delay

func set_mask_fade_speed(new_speed: float) -> void:
	assert(mesh is QuadMesh)
	var quad_mesh := mesh as QuadMesh
	
	assert(quad_mesh.material is ShaderMaterial)
	var shader := quad_mesh.material as ShaderMaterial
	
	shader.set_shader_parameter("mask_fade_speed", new_speed)

func set_animation_speed(new_speed: float) -> void:
	self.speed = new_speed
	assert(mesh is QuadMesh)
	var quad_mesh := mesh as QuadMesh
	
	assert(quad_mesh.material is ShaderMaterial)
	var shader := quad_mesh.material as ShaderMaterial
	
	shader.set_shader_parameter("speed", new_speed)

func _init() -> void:
	start_time = Time.get_ticks_msec()
	mesh = QuadMesh.new()
	mesh.material = bullet_trail_shader_material.duplicate(true)


func _process(_delta: float) -> void:
	assert(mesh is QuadMesh)
	var quad_mesh := mesh as QuadMesh
	
	assert(quad_mesh.material is ShaderMaterial)
	var shader := quad_mesh.material as ShaderMaterial
	var time = Time.get_ticks_msec()
	shader.set_shader_parameter("delay", delay)
	shader.set_shader_parameter("animation_time", time - start_time)
