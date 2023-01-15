shader_type spatial;
render_mode vertex_lighting, specular_disabled, diffuse_lambert;

uniform sampler2D grass_texture : source_color, filter_linear_mipmap;

void vertex(){
	NORMAL = vec3(0.0, 1.0, 0.0);
}

void fragment() {
// 	if (UV.y < 0.2) {
// 		discard;
// 	}
	vec4 t = texture(grass_texture, UV);
	if (t.a < 0.5) {
		discard;
	}
	ALBEDO = t.rgb;
}
