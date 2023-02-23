shader_type particles;



#include "heightsave.gdshaderinc"

uniform uint side;
uniform float chunk_size;
uniform sampler2D grass_density : filter_nearest;
uniform vec3 pos3;
uniform vec3 viewpoint;
uniform float reduce_radius_sq;



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
	float rot = rand_from_seed(hash(ind)) * TAU;
	uint pind = ind * 101u % (side * side);
	vec2 dpos = vec2(float(pind / side), float(pind % side)) / float(side) * chunk_size;
	vec2 core_pos = EMISSION_TRANSFORM[3].xz;
	vec2 base_pos = core_pos +  chunk_size - mod(core_pos + dpos, chunk_size);
	vec2 pos = base_pos + vec2(rand_from_seed(hash(ind * 7u + 53u)) - 0.5, rand_from_seed(hash(ind * 53u + 7u)) - 0.5) / (float(side) / chunk_size);
	float h = height_at(pos);
	vec2 uv = uv_at(pos);
	float density = texture(grass_density, uv).r;
	vec2 dir = vec2(-sin(rot), cos(rot));
	vec2 diff = viewpoint.xz - pos;
	vec2 diffsq = diff * diff;
	float distsq = diffsq.x + diffsq.y;

	if (distsq > reduce_radius_sq ) {
		density = min(density, 0.4);
	}
	ACTIVE = density > rand_from_seed(hash(ind * 103u + 13u));

	TRANSFORM = mat4(
		vec4( -dir.x, 0.0, dir.y, 0.0),
		vec4( 0.0, 1.0, 0.0, 0.0),
		vec4( -dir.y, 0.0, -dir.x, 0.0),
		vec4( pos.x, h, pos.y, 1.0)
	);

}

void process() {
}
