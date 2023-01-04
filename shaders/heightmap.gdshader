shader_type canvas_item;


#include "shaders/ashima_simplex.gdshaderinc"
#include "shaders/fastnoiselite.gdshaderinc"

uniform vec3 area_min;
uniform vec3 area_size;
uniform float shore_offset;
uniform float base_height;


float pow5(float x){
	return x * x * x * x * x;
}

float calc_shore(float dist) {
	float d = clamp(dist / shore_offset, 0.0, 1.0) - 1.0;
	return 1.0 - d * d;
}

float shore_factor(vec2 pos) {
	vec2 startdist = pos - area_min.xz;
	vec2 enddist = area_min.xz + area_size.xz - pos;
	return calc_shore(startdist.x) * calc_shore(startdist.y) * calc_shore(enddist.x) * calc_shore(enddist.y);
}

float height_at(vec2 pos) {

	fnl_state noise = fnlCreateState(1);

	float n = snoise(pos / 800.0) * 0.7
		+ snoise(pos / 200.0) * 0.19
		+ snoise(pos / 60.0) * 0.08
		+ snoise(pos / 30.0) * 0.02
		+ snoise(pos / 16.0) * 0.006;
		+ snoise(pos / 7.0) * 0.004;
	float h = (pow5(n+0.1)+ n/3.0 + 0.15) * 80.0;
	float n2 = fnlGetNoise2D(noise, pos.x/6.0, pos.y/6.0);
// 	float h2 = (pow5(n2) + 0.1) * 50.0;
	float h2 = (pow5(n2+0.0)+ n2/3.0 + 0.10) * 100.0;
	float shore = shore_factor(pos);
	return mix(base_height, h2, shore);
}




void fragment() {
	vec2 pos =  area_min.xz + UV * area_size.xz;
	float b = 255.0;
	float h = (height_at(pos) - area_min.y) / area_size.y;//(sin(pos.x) + sin(pos.y) + 2.0) / 4.0;
	float delta = 0.01;
	vec3 normals = normalize(-cross(
		vec3(-delta, h - height_at(pos + vec2(-delta, 0)), 0),
		vec3(0, h - height_at(pos + vec2(0, -delta)), -delta)
	));
	COLOR = vec4(floor(h*b)/b, fract(h*b), (normals.x + 1.0) / 2.0, 1.0);
}
