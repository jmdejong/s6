shader_type canvas_item;


#include "shaders/ashima_simplex.gdshaderinc"
#include "shaders/fastnoiselite.gdshaderinc"
#include "shaders/height_at.gdshaderinc"

void fragment() {
	vec2 pos = uv_to_pos(UV);
	float h = height_at(pos);
	float delta = 0.1;
	vec3 normal = normalize(cross(
		vec3(-delta, h - height_at(pos + vec2(-delta, 0)), 0),
		vec3(0, h - height_at(pos + vec2(0, -delta)), -delta)
	));
	normal.y *= -1.0;
	COLOR = vec4((normal + 1.0 ) / 2.0, 1.0);
}
