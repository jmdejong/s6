shader_type particles;



#include "shaders/heightsave.gdshaderinc"

uniform uint side;
uniform float chunk_size;
uniform sampler2D grass_density : filter_nearest;
uniform vec3 pos3;
uniform vec3 viewpoint;



float rand_from_seed(in uint seed) {
	int k;
	int s = int(seed);
	if (s == 0) {
		s = 305420679;
	}
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0){
		s += 2147483647;
	}
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}


void start() {
	uint ind = INDEX;
// 	bool back = INDEX % 2u == 1u;
	float rot = rand_from_seed(hash(ind)) * TAU;
// 	if (back) {
// 		rot += PI;
// 		ACTIVE = false;
// 	}
	uint pind = ind * 101u % (side * side);
	vec2 dpos = vec2(float(pind / side), float(pind % side)) / float(side) * chunk_size;
	vec2 pos = dpos + EMISSION_TRANSFORM[3].xz + vec2(rand_from_seed(hash(ind * 7u + 53u)) - 0.5, rand_from_seed(hash(ind * 53u + 7u)) - 0.5) / (float(side) / chunk_size);
	float h = height_at(pos);
	vec2 uv = uv_at(pos);
	float density = texture(grass_density, uv).r;
	vec2 dir = vec2(-sin(rot), cos(rot));
	float dp = dot(dir.yx, normalize(pos - viewpoint.xz));
	vec2 diff = viewpoint.xz - pos;
	vec2 diffsq = diff * diff;
	float distsq = diffsq.x + diffsq.y;
// 	if (distsq > chunk_size* chunk_size * 2.0 ) {
// 		density = min(density, 0.4);
// 	}
	if (density < rand_from_seed(hash(ind * 103u + 13u)) || distsq > chunk_size* chunk_size * 2.0 && abs(dp) < 0.5) {
		ACTIVE = false;
	}
	dir *= sign(dp);

	TRANSFORM = mat4(
		vec4( -dir.x, 0.0, dir.y, 0.0),
		vec4( 0.0, 1.0, 0.0, 0.0),
		vec4( -dir.y, 0.0, -dir.x, 0.0),
		vec4( pos.x, h, pos.y, 1.0)
	);

}

void process() {
	// Place process code here.
}
