shader_type spatial;
render_mode world_vertex_coords, specular_disabled;


#include "shaders/ashima_simplex.gdshaderinc"


// uniform sampler2D grass_texture : source_color, filter_linear_mipmap;
// uniform sampler2D sand_texture : source_color, filter_linear_mipmap;
// uniform sampler2D stone_texture : source_color, filter_linear_mipmap;
uniform sampler2DArray textures : source_color, filter_linear_mipmap;
uniform sampler2D current_texture : filter_nearest;
uniform float texture_size;

#include "shaders/heightsave.gdshaderinc"

varying vec3 normals;
// varying vec2 tex_uv;
varying vec3 p;

float asdf(float x, float y) {
	return x * y;//smoothstep(0.0, 1.0, 1.0 * x * x +  y * y);// + x * x + y * y;
}

vec4 contributions(vec2 uv){
	return vec4(
		asdf(1.0 - uv.x, 1.0 - uv.y),
		asdf(uv.x, 1.0 - uv.y),
		asdf(1.0 - uv.x, uv.y),
		asdf(uv.x, uv.y)
	);
}

vec4 nrm(vec4 i) {
	return i / (i.x + i.y + i.z + i.w);
}

void vertex() {
// 	vec2 pos = clamp(VERTEX.xz, area_min.xz, area_size.xz + area_min.xz);
	vec2 pos = VERTEX.xz;
	float k = height_at(pos);
	VERTEX.y = k;
	normals = normal_at(pos);
	NORMAL = normals;
	p = VERTEX;
}

// vec3 ignore_rest(vec4 i){
// 	if (i.x > i.y && i.x > i.z){
// 		return vec3(i.x, 0, 0);
// 	} else if (i.y > i.z){
// 		return vec3(0, i.y, 0);
// 	} else {
// 		return vec3(0, 0, i.z);
// 	}
// }

vec3 ignore_rest(vec4 i){
	if (i.x > i.y && i.x > i.z){
		return vec3(1.0, 0, 0);
	} else if (i.y > i.z){
		return vec3(0, 1.0, 0);
	} else {
		return vec3(0, 0, 1.0);
	}
}

int texid(vec4 c) {
	return int(round(c.r * 100.0));
}

vec4 teq(int val, ivec4 vec) {
	return 1.0 - vec4(abs(sign(vec - val)));
}

vec4 interpolate_texture(vec2 big_uv, out vec4 te) {
	ivec2 size = textureSize(current_texture, 0);
	vec2 xy = big_uv * vec2(size);
	ivec2 ixy = ivec2(floor(xy));
	vec2 uv = fract(xy);
// 	uv *= uv * uv;
// 	uv = smoothstep(0.3, 0.7, uv);
	vec4 c = contributions(uv);
// 	c = nrm(smoothstep(0.3, 0.7, c));
	ivec4 t = ivec4(
		texid(texelFetch(current_texture, ixy, 0)),
		texid(texelFetch(current_texture, ixy + ivec2(1, 0), 0)),
		texid(texelFetch(current_texture, ixy + ivec2(0, 1), 0)),
		texid(texelFetch(current_texture, ixy + ivec2(1, 1), 0))
	);
	te = vec4(t);
	vec4 tt =
		teq(t.x, t) * c.x +
		teq(t.y, t) * c.y +
		teq(t.z, t) * c.z +
		teq(t.w, t) * c.w;
	return tt;
// 	return vec4((
// 		ignore_rest(texelFetch(current_texture, ixy, 0)) * c.x +
// 		ignore_rest(texelFetch(current_texture, ixy + ivec2(1, 0), 0)) * c.y +
// 		ignore_rest(texelFetch(current_texture, ixy + ivec2(0, 1), 0)) * c.z +
// 		ignore_rest(texelFetch(current_texture, ixy + ivec2(1, 1), 0)) * c.w
// 	).xyz, 0);
// 	return mix(
// 		mix(
// 			texelFetch(current_texture, ixy, 0),
// 			texelFetch(current_texture, ixy + ivec2(1, 0), 0),
// 			smoothstep(0.2, 0.8, uv.x)
// 		),
// 		mix(
// 			texelFetch(current_texture, ixy + ivec2(0, 1), 0),
// 			texelFetch(current_texture, ixy + ivec2(1, 1), 0),
// 			smoothstep(0.2, 0.8, uv.x)
// 		),
// 		smoothstep(0.2, 0.8, uv.y)
// 	).xyz;
}


void fragment() {

	vec2 tex_uv = fract(p.xz / texture_size);
	vec4 te;
	vec4 tt = interpolate_texture(uv_at(p.xz), te);
	vec4 cur = nrm(tt * tt * tt * tt * tt* tt * tt * tt * tt);//texture(current_texture, uv_at(p.xz)).xyz;
// 	vec3 cur = interpolate_texture(uv_at(p.xz));
	vec4 t =
		texture(textures, vec3(tex_uv, te.x)) * cur.x +
		texture(textures, vec3(tex_uv, te.y)) * cur.y +
		texture(textures, vec3(tex_uv, te.z)) * cur.z +
		texture(textures, vec3(tex_uv, te.w)) * cur.w;
	float blueness = clamp(1.0 + (p.y)/8.0, 0.1, 1.0);
	float darkness = clamp(1.0 + (p.y)/16.0, 0.1, 1.0);
// 	float blueness = smoothstep(-4.0, 0.0, p.y);
	vec3 underwater = vec3(blueness, blueness, darkness);
	ALBEDO = t.xyz * underwater * underwater * underwater* underwater;
}
