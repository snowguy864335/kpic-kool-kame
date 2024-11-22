/*

LineRendering solution

create a MeshInstance3D
set the mesh as a quad (default settings)
set texture (a vertical gradient with alpha looks best)

the quad is stretched into position based on the parameters and rotation, you can also set the default axis (default +y)

modified from:
https://godotshaders.com/shader/billboard-sprite3d-hitflash-godot-4-x/

*/

shader_type spatial;
render_mode unshaded, cull_disabled; // optional
 
uniform sampler2D mask: repeat_enable;
uniform float line_width = 1.0;
uniform float line_length = 1.0; // set this larger to stretch the line
uniform vec3 default_axis = vec3(0.0, 1.0, 0.0); // default axis the line follows before rotation (rotate the nodes transform)
uniform float animation_time = 0.0;
uniform float delay = 0.0;
uniform float speed = 5.0;
uniform float mask_fade_speed = 0.0;

varying vec2 LINE_DIM; // Passed from vertex to fragment
varying float len;
void vertex() {
	VERTEX += vec3(0,0.5,0);
	VERTEX.y *= line_length;
	VERTEX.x *= line_width; // thin or fat line
	
	
    
    vec3 _target_position = normalize((MODEL_MATRIX * vec4(default_axis.x, default_axis.y, default_axis.z, 0.0)).xyz);
    MODELVIEW_MATRIX = VIEW_MATRIX *
        mat4(
            vec4(normalize(cross(_target_position, INV_VIEW_MATRIX[2].xyz)), 0.0),
            vec4(_target_position.x, _target_position.y, _target_position.z, 0.0),
            vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, _target_position)), 0.0),
            MODEL_MATRIX[3]);
	
	LINE_DIM = VERTEX.xy;
	float real_time = max(animation_time - delay, 0);
	len = real_time / 1000.0 * speed;
}

void fragment() {
	float real_time = max(animation_time - delay, 0);
	
	vec2 uv = UV;
	uv.y = 1.0 - clamp(len - LINE_DIM.y, 0, 1);
	
	vec4 _color = vec4(1, 1, 1, 0);
	vec4 bullet_color = vec4(1, 1, 1, 0.6);
	_color = mix(_color, bullet_color, uv.y);
	uv.x *= line_width;
	uv.y *= LINE_DIM.y - real_time / speed;
	
	float threshold = clamp(animation_time * mask_fade_speed, 0, 1);
	
	ALBEDO = _color.rgb;
	
	ALPHA = _color.a * clamp(texture(mask, vec2(uv.x, uv.y * 4.)).r - threshold, 0, 1);
}