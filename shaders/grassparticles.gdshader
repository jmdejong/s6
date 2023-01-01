shader_type particles;

uniform sampler2D noise;
uniform vec3 area_min;
uniform vec3 area_size;
uniform uint side;
uniform vec2 chunk_min;
uniform vec2 chunk_size;
// uniform float rot;



vec4 interpolate_sample(sampler2D tex, vec2 big_uv, int lod) {
	ivec2 size = textureSize(tex, lod);
	vec2 xy = big_uv * vec2(size);
	ivec2 ixy = ivec2(floor(xy));
	vec2 uv = fract(xy);
// 	return texelFetch(tex, ixy, lod);
	return mix(
			mix(
			texelFetch(tex, ixy, lod),
			texelFetch(tex, ixy + ivec2(1, 0), lod),
			uv.x
		),
		mix(
			texelFetch(tex, ixy + ivec2(0, 1), lod),
			texelFetch(tex, ixy + ivec2(1, 1), lod),
			uv.x
		),
		uv.y
	);
}


float height_at(vec2 position) {
	vec2 uv = (position - area_min.xz) / area_size.xz;
	vec4 tex = interpolate_sample(noise, uv, 0);
// 	vec4 tex = texture(noise, uv);
	return (tex.x + tex.y / 255.0 ) * area_size.y + area_min.y;
// 	return (tex.x) * area_size.y + area_min.y;
}



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

// const float side = 64.0;
// const uint uside = 64u;


void start() {
	float rot = rand_from_seed(hash(INDEX)) * TAU;
	uint pind = INDEX * 101u % (side * side);
	vec2 dpos = vec2(float(pind / side), float(pind % side)) / float(side) * chunk_size;
	vec2 pos = dpos + EMISSION_TRANSFORM[3].xz;
	float h = height_at(pos);
	TRANSFORM = mat4(
		vec4( cos(rot), 0.0, sin(rot), 0.0),
		vec4( 0.0, 1.0, 0.0, 0.0),
		vec4( -sin(rot), 0.0, cos(rot), 0.0),
		vec4( pos.x, h, pos.y, 1.0)
	);
}

void process() {
	// Place process code here.
}
