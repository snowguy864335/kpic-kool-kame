shader_type spatial;
render_mode unshaded, shadows_disabled, cull_disabled;

uniform sampler2D lightning_texture;
uniform vec3 lightning_color : source_color;

void vertex() {
	vec3 up = (vec4(0, 1, 0, 0)).xyz;
	vec3 dir = (vec4(CAMERA_POSITION_WORLD - NODE_POSITION_WORLD, 0.) * MODEL_MATRIX).xyz;

	dir.y = 0.;
	dir = normalize(dir);
	mat3 bt = mat3(cross(up, dir), up, dir);
	VERTEX = bt * VERTEX;
}

void fragment() {
	vec2 samplePos = vec2(UV.y, UV.x - TIME);
	ALBEDO = texture(lightning_texture, samplePos).r * lightning_color;
	ALPHA = texture(lightning_texture, samplePos).r;
}
