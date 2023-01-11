shader_type canvas_item;

#include "shaders/fastnoiselite.gdshaderinc"
#include "shaders/heightsave.gdshaderinc"



void fragment() {

	fnl_state noise = fnlCreateState(2);
	vec2 pos = UV * area_size.xz + area_min.xz;
	float h = height_at(pos);
	float density = 0.0;
	if (h > 2.0) {
		float d = 1.0;//smoothstep(-0.1, 0.1, fnlGetNoise2D(noise, pos.x/3.0, pos.y/3.0));
		density = d - (h - 20.0)/40.0;
	}
	density *= smoothstep(0.94, 0.95, normal_at(pos).y);//clamp(normal_at(pos).y * 4.0 - 2.0, 0.0, 1.0);
	COLOR = vec4(density, density, density, 1.0);
}
