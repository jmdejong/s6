extends Node3D

@export var source: Node
@export var particle_material: Material
@export var mesh: Mesh
@export var chunk_size = 32
@export var chunk_distance = 3
@export var max_chunks = 100
@export var particles_per_meter = 2

var _last_viewpoint = null
var _loaded_chunks = {}



func add_grass_area(area):
	var node = GPUParticles3D.new()
	node.position = Vector3(area.position.x, 0, area.position.y)
	node.custom_aabb = AABB(Vector3(0, source.aabb.position.y, 0), Vector3(area.size.x, source.aabb.size.y, area.size.y))
	particle_material.set_shader_parameter("area_min", source.aabb.position)
	particle_material.set_shader_parameter("area_size", source.aabb.size)
	particle_material.set_shader_parameter("side", particles_per_meter * area.size.x)
	particle_material.set_shader_parameter("chunk_min", area.position)
	particle_material.set_shader_parameter("chunk_size", area.size)
	particle_material.set_shader_parameter("noise", source.height_texture())
	node.process_material = particle_material
	node.amount = area.get_area() * particles_per_meter * particles_per_meter
	node.draw_pass_1 = mesh
	add_child(node)
	return node


func remove_furthest():
	var furthest_distance = 0
	var furthest
	for p in _loaded_chunks:
		var d = p.distance_squared_to(_last_viewpoint)
		if d > furthest_distance:
			furthest = p
			furthest_distance = d
	var furthest_node = _loaded_chunks[furthest]
	furthest_node.queue_free()
	_loaded_chunks.erase(furthest)

func update_viewpoint(pos3):
	var pos = Vector2(pos3.x, pos3.z)
	var snapped_viewpoint = pos.snapped(Vector2(chunk_size, chunk_size))
	if _last_viewpoint == snapped_viewpoint or not source.is_ready:
		return
	_last_viewpoint = snapped_viewpoint

	var dd = chunk_distance * chunk_size

	var to_clear = []
	for chunkpos in _loaded_chunks:
		var dp = (snapped_viewpoint - chunkpos).abs()
		var d = max(dp.x, dp.y)
		if d > dd + chunk_size:
			to_clear.push_back(chunkpos)
			_loaded_chunks[chunkpos].queue_free()
	for chunkpos in to_clear:
		_loaded_chunks.erase(chunkpos)

	for x in range(snapped_viewpoint.x - dd, snapped_viewpoint.x + dd, chunk_size):
		for y in range(snapped_viewpoint.y - dd, snapped_viewpoint.y + dd, chunk_size):
			var v = Vector2(x, y)
			if not (v in _loaded_chunks):
				_loaded_chunks[v] = add_grass_area(Rect2(v, Vector2(chunk_size, chunk_size)))
