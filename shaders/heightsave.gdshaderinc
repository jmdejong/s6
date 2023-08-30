
uniform sampler2D height_input : filter_nearest;
uniform sampler2D normal_input : filter_linear;
uniform vec3 area_min;
uniform vec3 area_size;


vec2 uv_at(vec2 position) {
	return (clamp(position, area_min.xz, area_size.xz + area_min.xz) - area_min.xz) / area_size.xz;
}



float raw_height_at(ivec2 ixy) {
	vec4 s = texelFetch(height_input, ixy, 0);
	return (s.x + s.y / 255.0 ) * area_size.y + area_min.y;
}

float interpolate_height(sampler2D tex, vec2 big_uv) {
	// To do (once I feel like it): use a cubic bezier interpolation instead of linear
	ivec2 size = textureSize(tex, 0);
	vec2 xy = big_uv * vec2(size);
	ivec2 ixy = ivec2(floor(xy));
	vec2 uv = fract(xy);
	return mix(
		mix(
			raw_height_at(ixy),
			raw_height_at(ixy + ivec2(1, 0)),
			uv.x
		),
		mix(
			raw_height_at(ixy + ivec2(0, 1)),
			raw_height_at(ixy + ivec2(1, 1)),
			uv.x
		),
		uv.y
	);
}

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
	vec2 uv = uv_at(position);
	return interpolate_height(height_input, uv);
// 	vec4 tex = interpolate_sample(height_input, uv, 0);
// 	vec4 tex = texture(height_input, uv_at(position));
// 	return (tex.x + tex.y / 255.0 ) * area_size.y + area_min.y;
}

vec3 normal_at(vec2 position) {
//     vec3 va = normalize(vec3(2,0,height_at(position + vec2(-0.01, 0)) - height_at(position + vec2(0.01, 0)));
//     vec3 vb = normalize(vec3(size.yx,s12-s10));
// 	return
	return normalize(texture(normal_input, uv_at(position)).xyz * 2.0 - 1.0);
}


