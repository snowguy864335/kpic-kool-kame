shader_type spatial;
uniform vec4 emission_color : hint_color;

void fragment() {
    ALBEDO = vec3(1.0); // Set the base color (can be customized)
    EMISSION = emission_color.rgb; // Set the emission color
void vertex() {
	// Called for every vertex the material is visible on.
}


//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
