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

uniform sampler2D albedo: hint_default_white; // the laser texture, a vertical gradient is suggested

uniform float line_width = 1.0;
uniform float line_length = 1.0; // set this larger to stretch the line

uniform bool correct_uv = false; // correct the uv stretching

uniform vec3 default_axis = vec3(0.0, 1.0, 0.0); // default axis the line follows before rotation (rotate the nodes transform)

uniform vec4 color: source_color = vec4(1.0); // modulate the color

uniform float brightness = 1.0; // make extra bright, good for lasers

uniform float animation_time = 0.0;

const float speed = 50.0;

varying vec2 LINE_DIM;
varying float len;


void vertex() {
	
	
	
	
	VERTEX += vec3(0,0.5,0); // correction for quad to make it stretch correctly
	
	//VERTEX.y *= clamp(animation_time / 1000.0 * speed, 0, line_length); // stretch the lines length
	VERTEX.y *= line_length;
	VERTEX.x *= line_width; // thin or fat line
	
	
    
    vec3 _target_position = normalize((MODEL_MATRIX * vec4(default_axis.x, default_axis.y, default_axis.z, 0.0)).xyz);
    
    // this is the same as a the y-billboard code but we can set any vector as the direction
    // as a consequence of the matrix, it also stretches the line!
    MODELVIEW_MATRIX = VIEW_MATRIX *
        mat4(
            vec4(normalize(cross(_target_position, INV_VIEW_MATRIX[2].xyz)), 0.0),
            vec4(_target_position.x, _target_position.y, _target_position.z, 0.0),
            vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, _target_position)), 0.0),
            MODEL_MATRIX[3]);
    
    //cargo code? i probabally don't need this unless we try to use normal maps
    //MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX); 
	
	LINE_DIM = VERTEX.xy;
	len = animation_time / 1000.0 * speed;
}

void fragment() {
	vec2 uv = UV;
	
	
	
	
	uv.y = 1.0 - clamp(len - LINE_DIM.y, 0, 1);
	
	vec4 _color = vec4(1, 1, 1, 0);
	vec4 bullet_color = vec4(1, 1, 1, 0.6);
	_color = mix(_color, bullet_color, pow(uv.y, 2));
	
	
	ALBEDO = _color.rgb;
	ALPHA = _color.a;
}