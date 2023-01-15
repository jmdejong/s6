shader_type particles;



#include "shaders/heightsave.gdshaderinc"

uniform uint side;
uniform float chunk_size;
uniform sampler2D grass_density : filter_nearest;
uniform vec3 pos3;
uniform vec3 viewpoint;
uniform float reduce_radius_sq;

const vec2 scale = vec2(0.5, 0.5);

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
	vec2 dir = vec2(cos(rot), -sin(rot));
	vec2 diff = viewpoint.xz - pos;
	vec2 diffsq = diff * diff;
	float distsq = diffsq.x + diffsq.y;

	if (distsq > reduce_radius_sq ) {
		density = min(density, 0.4);
	}
	ACTIVE = density > rand_from_seed(hash(ind * 103u + 13u));

// 	TRANSFORM = mat4(
// 		vec4( dir.x * scale.x, 0.0, dir.y * scale.x, 0.0),
// 		vec4( 0.0, scale.y, 0.0, 0.0),
// 		vec4( -dir.y * scale.x, 0.0, dir.x * scale.x, 0.0),
// 		vec4( pos.x, h, pos.y, 1.0)
// 	);
	vec3 normal = normal_at(pos);

	mat4 transform1 = mat4(
		vec4( normal.y, -normal.x, 0.0, 0.0),
		vec4( normal.x, normal.y, normal.z, 0.0),
		vec4( 0.0, -normal.z, normal.y , 0.0),
		vec4( pos.x, h, pos.y, 1.0)
	);
	mat4 transform2 = mat4(
		vec4( dir.x, 0.0, dir.y, 0.0),
		vec4( 0.0, 1.0, 0.0, 0.0),
		vec4(-dir.y, 0.0, dir.x , 0.0),
		vec4( 0.0, 0.0, 0.0, 1.0)
	);
	mat4 transform3 = mat4(
		vec4(scale.x, 0.0, 0.0, 0.0),
		vec4(0.0, scale.y, 0.0, 0.0),
		vec4(0.0, 0.0, scale.x, 0.0),
		vec4(0.0, 0.0, 0.0, 1.0)
	);
	TRANSFORM = transform1 * transform2 * transform3;

}

void process() {
	// Place process code here.
}
