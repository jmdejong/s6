shader_type canvas_item;


#include "shaders/heightsave.gdshaderinc"


void fragment() {
	vec2 pos = UV * area_size.xz + area_min.xz;
	vec3 current = mix(
		vec3(0.0, 0.0, 1.0),
		mix(
			vec3(0.0, 1.0, 0.0),
			vec3(1.0, 0.0, 0.0),
			clamp((height_at(pos) - 1.5) * 50.0, 0.0, 1.0)
		),
		clamp((normal_at(pos).y - 0.7) * 100.0, 0, 1.0)
	);
	int t = 0;
	if (normal_at(pos).y < 0.7) {
		t = 2;
	} else if (height_at(pos) < 2.0) {
		t = 1;
	}
// 	COLOR = vec4(current, 1.0);
	COLOR = vec4(float(t) / 100.0, 0.0, 0.0, 1.0);
}
