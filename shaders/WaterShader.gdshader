shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform float speed: hint_range(-1, 1) = 0.0;
uniform float normal_strength: hint_range(0, 1) = 0.5;

uniform sampler2D noise1;
uniform sampler2D noise2;
uniform sampler2D normalmap : hint_normal;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform vec4 color : source_color;
uniform vec4 edge_color : source_color;

//foam
uniform float edge_scale = 0.25;
uniform float near = 0.1;
uniform float far = 100.0;

uniform vec2 uv_offset_size = vec2(1, 1);

float rim(float depth){
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}

void fragment() {
	float time = TIME * speed;
	
	vec2 uv = UV;
	uv.y += sin(uv.x * 15.0 + time) * 0.05 ;
	
	vec3 n1 =  texture(noise1, uv + time).rgb;
	vec3 n2 = texture(noise2, UV - time * 0.2).rgb;
	
	vec2 uv_movement = UV * 4.0;
	uv_movement += TIME * speed * 4.0;
	
	float sum = (n1.r + n2.r) - 1.0;
	
	float z_depth = rim((texture(DEPTH_TEXTURE, SCREEN_UV).x));
	float z_pos = rim(FRAGCOORD.z);
	float diff = z_depth - z_pos;
	
	vec2 displacement = vec2(sum);
	diff += displacement.x * 0.1;
	
	vec4 col = mix(edge_color, color, step(edge_scale, diff));
	
	vec4 alpha = texture(SCREEN_TEXTURE, SCREEN_UV + displacement);
	
	float fin = 0.0;
	if(sum > 0.0 && sum < 0.4) fin = 0.01;
	if(sum > 0.4 && sum < 0.8) fin = 0.0;
	if(sum > 0.8) fin = 1.0;
	
	ALBEDO = vec3(fin) + mix(alpha.rgb, col.rgb, color.a);
	
	NORMAL_MAP = texture(normalmap,uv_movement).rbg;
	NORMAL_MAP_DEPTH = normal_strength;
	ROUGHNESS = 0.3;
	SPECULAR = 0.1;
}
