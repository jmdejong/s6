extends Node3D

@export var source: Node
@export var mesh: Mesh
@export var chunk_size = 32
@export var chunk_distance = 4
@export var particles_per_meter : float = 2

var _last_viewpoint = null
var _loaded_chunks = {}
var _particle_material = ShaderMaterial.new()
var _particle_shader = preload("res://shaders/grassparticles.gdshader")

func _ready():
	await source.await_creation()
	_particle_material.shader = _particle_shader
	_particle_material.set_shader_parameter("area_min", source.aabb.position)
	_particle_material.set_shader_parameter("area_size", source.aabb.size)
	_particle_material.set_shader_parameter("side", particles_per_meter * chunk_size)
	_particle_material.set_shader_parameter("chunk_size", chunk_size)
	_particle_material.set_shader_parameter("height_input", source.height_texture())
	_particle_material.set_shader_parameter("normal_input", source.normal_texture())
	_particle_material.set_shader_parameter("grass_density", source.grass_density_texture())

func add_grass_area(area):
	var node = GPUParticles3D.new()
	node.draw_order = 3
	node.position = Vector3(area.position.x, 0, area.position.y)
	node.custom_aabb = AABB(Vector3(0, source.aabb.position.y, 0), Vector3(area.size.x, source.aabb.size.y, area.size.y))
	node.process_material = _particle_material
	node.amount = area.get_area() * particles_per_meter * particles_per_meter
	node.draw_pass_1 = mesh
	node.cast_shadow = false
	add_child(node)
	return node



func update_viewpoint(pos3):
	_particle_material.set_shader_parameter("viewpoint", pos3)
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
	for chunkpos in to_clear:
		_loaded_chunks[chunkpos].queue_free()
		_loaded_chunks.erase(chunkpos)

	for x in range(snapped_viewpoint.x - dd, snapped_viewpoint.x + dd, chunk_size):
		for y in range(snapped_viewpoint.y - dd, snapped_viewpoint.y + dd, chunk_size):
			var v = Vector2(x, y)
			if not (v in _loaded_chunks):
				_loaded_chunks[v] = add_grass_area(Rect2(v, Vector2(chunk_size, chunk_size)))


func _input(event):
	if event.is_action_pressed("toggle_grass"):
		visible = not visible

