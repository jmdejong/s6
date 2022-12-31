


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
}
