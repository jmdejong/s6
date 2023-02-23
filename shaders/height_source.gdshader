shader_type canvas_item;


#include "ashima_simplex.gdshaderinc"
#include "fastnoiselite.gdshaderinc"
#include "height_at.gdshaderinc"


void fragment() {
	vec2 pos = uv_to_pos(UV);
	float h = height_proportion(height_at(pos));
	float b = 255.0;
	COLOR = vec4(floor(h*b)/b, fract(h*b), 1.0, 1.0);
}
