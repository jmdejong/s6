shader_type canvas_item;


#include "shaders/ashima_simplex.gdshaderinc"
#include "shaders/fastnoiselite.gdshaderinc"
#include "shaders/height_at.gdshaderinc"


void fragment() {
	vec2 pos = uv_to_pos(UV);
	float h = height_proportion(height_at(pos));
	float b = 255.0;
	COLOR = vec4(floor(h*b)/b, fract(h*b), 0.0, 1.0);
}
