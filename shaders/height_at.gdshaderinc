

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
	noise.octaves = 8;

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


vec2 uv_to_pos(vec2 uv) {
	return area_min.xz + uv * area_size.xz;
}

float height_proportion(float height){
	return (height - area_min.y) / area_size.y;
}
