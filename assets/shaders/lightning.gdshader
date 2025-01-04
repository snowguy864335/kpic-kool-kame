shader_type spatial;
render_mode unshaded, shadows_disabled, cull_disabled;

uniform sampler2D lightning_texture;
uniform sampler2D noise_texture;
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
	vec2 sample_pos = vec2(UV.x, UV.y - TIME * 1.5);
	vec2 noise_sample_pos = vec2(sample_pos.x, sample_pos.y - TIME * 0.6);
	ALBEDO = max(pow(texture(lightning_texture, sample_pos).r,3) - texture(noise_texture, noise_sample_pos).r / 5., 0.0) * lightning_color;
	ALPHA = pow(length(ALBEDO),2);
}
