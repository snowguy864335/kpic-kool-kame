shader_type spatial;
render_mode unshaded;

uniform sampler3D distortionTexture;
uniform sampler3D albedoTexture;

uniform vec3 color1 : source_color;
uniform vec3 color2 : source_color;

void vertex() {
	vec4 world_coord = MODEL_MATRIX *  vec4(VERTEX, 1.);
	VERTEX += NORMAL * texture(distortionTexture, world_coord.xyz / 4.).r * 0.05;
}

void fragment() {
	
	vec4 world_coord = INV_VIEW_MATRIX * vec4(VERTEX, 1.);
	ALBEDO =  mix(color1, color2, texture(albedoTexture, world_coord.xyz).r);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
