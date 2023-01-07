shader_type spatial;
render_mode world_vertex_coords;


#include "shaders/ashima_simplex.gdshaderinc"


// uniform sampler2D grass_texture : source_color, filter_linear_mipmap;
// uniform sampler2D sand_texture : source_color, filter_linear_mipmap;
// uniform sampler2D stone_texture : source_color, filter_linear_mipmap;
uniform sampler2DArray textures : source_color, filter_linear_mipmap;
// uniform sampler2DArray texes : source_color, filter_linear_mipmap;
uniform float texture_size;

#include "shaders/heightsave.gdshaderinc"

varying vec3 normals;
// varying vec2 tex_uv;
varying vec3 p;



void vertex() {
// 	vec2 pos = clamp(VERTEX.xz, area_min.xz, area_size.xz + area_min.xz);
	vec2 pos = VERTEX.xz;
	float k = height_at(pos);
	VERTEX.y = k;
	normals = normal_at(pos);
	NORMAL = normals;
	p = VERTEX;
}


void fragment() {

// 	if (p.y < -0.01) {
// 		discard;
// 	}
	vec2 tex_uv = fract(p.xz / texture_size);
// 	sampler2D tex = normals.y > 0.7 ? stone_texture : p.y < 2.0 ? sand_texture : grass_texture;
	vec4 t =
		mix(
// 			vec4(0.4, 0.4, 0.4, 1.0),
			texture(textures, vec3(tex_uv, 2.0)),
			mix(
// 				vec4(1.0, 1.0, 0.1, 1),
// 				vec4(0.0, 1.0, 0.1, 1),
				texture(textures, vec3(tex_uv, 1.0)),
				texture(textures, vec3(tex_uv, 0.0)),
				clamp((p.y + snoise(p.xz * 20.0) * 0.02 + snoise(p.xz * 1.0) * 0.1 + snoise(p.xz * 0.05) * 0.4 - 1.5) * 50.0, 0.0, 1.0)
			),
			clamp((normals.y - 0.7)* 100.0, 0, 1)
		);
	float sea_height = clamp(1.0 + p.y/4.0, 0.0, 1.0);
	vec3 blue = vec3(sea_height, sea_height, 1.0);
	ALBEDO = t.xyz * blue * blue;
// 	ALBEDO = mix(
// 		texture(stone_texture, tex_uv).xyz,
// 		mix(
// 			texture(sand_texture, tex_uv).xyz,
// 			texture(grass_texture, tex_uv).xyz,
// 			clamp(vert_height*2.0-3.0, 0.0, 1.0)
// 		),
// 		clamp((normals.y - 0.7)* 20.0, 0, 1)
// 	);
// 	ALBEDO = mix(
// 		vec3(0.1, 0.1, 0.1),
// 		mix(
// 			vec3(0.6, 0.6, 0),
// 			vec3(0, 0.5, 0),
// 			clamp(vert_height*2.0-3.0, 0.0, 1.0)
// 		),
// 		clamp((normals.y - 0.7)* 20.0, 0, 1)
// 	);
}
