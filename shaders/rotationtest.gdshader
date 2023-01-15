shader_type spatial;

const vec2 scale = vec2(1, 1);
const vec2 pos = vec2(1, 2);
const float h = 0.1;
const vec3 normal = normalize(vec3(1.0, 2.0, 1.0));

void vertex() {
	float rot = TIME;
	vec2 dir = vec2(cos(rot), -sin(rot));

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
	VERTEX = (transform1 * transform2 * vec4(VERTEX, 1.0)).xyz;
}
