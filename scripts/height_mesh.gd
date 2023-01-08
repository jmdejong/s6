extends Node3D

@export var chunk_resolution = 64
@export var center_size = 64
@export var snap_size = 32
@export var view_dist = 2048
@export var textures : TextureLayered
@export var water_material: Material
@export var source: Node
@export var texture_size = 2

var aabb
var area
var chunk_mesh
var water_mesh

var _height_material = ShaderMaterial.new()
var _mesh_shader = preload("res://shaders/meshterrain.gdshader")

const tile_centers = [
	Vector2(-1.5, -1.5),
	Vector2(1.5, -1.5),
	Vector2(-1.5, 1.5),
	Vector2(1.5, 1.5),
	Vector2(-0.5, -1.5),
	Vector2(0.5, -1.5),
	Vector2(-0.5, 1.5),
	Vector2(0.5, 1.5),
	Vector2(-1.5, -0.5),
	Vector2(1.5, -0.5),
	Vector2(-1.5, 0.5),
	Vector2(1.5, 0.5),
]

func _ready():
	for argument in OS.get_cmdline_args():
		if argument == "--lores":
			chunk_resolution = 16
			view_dist = 512
	await source.await_creation()
	aabb = source.aabb
	area = Rect2(aabb.position.x, aabb.position.z, aabb.size.x, aabb.size.z)
	_height_material.shader = _mesh_shader
	_height_material.set_shader_parameter("height_input", source.height_texture)
	_height_material.set_shader_parameter("normal_input", source.normal_texture)
	_height_material.set_shader_parameter("current_texture", source.current_texture)
	_height_material.set_shader_parameter("area_min", aabb.position)
	_height_material.set_shader_parameter("area_size", aabb.size)
	_height_material.set_shader_parameter("textures", textures)
	_height_material.set_shader_parameter("texture_size", texture_size)
	
	chunk_mesh = create_mesh(_height_material)
	water_mesh = create_mesh(water_material)

	var size = center_size
	for tc in [Vector2(-0.5, -0.5), Vector2(0.5, -0.5), Vector2(-0.5, 0.5), Vector2(0.5, 0.5)]:
		add_chunk(tc * size, size, chunk_mesh)
		add_chunk(tc * size, size, water_mesh)
	while size < view_dist:
		for tc in tile_centers:
			add_chunk(tc * size, size, chunk_mesh)
			add_chunk(tc * size, size, water_mesh)
		size *= 2
	

	# print(Time.get_ticks_msec()," starting collision shape gen")
	# $Collision/Shape.shape.map_width = int(area.size.x * source.resolution)
	# $Collision/Shape.shape.map_depth = int(area.size.y * source.resolution)
	# print(Time.get_ticks_msec()," starting collision shape loop")
	# var heightdata = source.get_all_heights()
	# print(Time.get_ticks_msec()," finished collision shape gen")
	# assert(heightdata.size() == $Collision/Shape.shape.map_data.size(), "collision heightmap sizes don't match")
	# $Collision/Shape.shape.map_data = heightdata
	# for x in area.size.x:
		# for y in area.size.y:
			

func create_mesh(material):
	var mesh = PlaneMesh.new()
	mesh.size = Vector2(1, 1)
	mesh.subdivide_width = chunk_resolution - 1
	mesh.subdivide_depth = chunk_resolution - 1
	mesh.custom_aabb = AABB(
		Vector3(-0.5, aabb.position.y, -0.5),
		Vector3(1, aabb.size.y, 1)
	)
	mesh.material = material
	return mesh

func add_chunk(pos: Vector2, size: float, mesh: Mesh):
	var chunk = MeshInstance3D.new()
	chunk.position = Vector3(pos.x, 0, pos.y)
	chunk.scale = Vector3(size, 1, size)
	chunk.mesh = mesh
	chunk.cast_shadow = true
	$Meshes.add_child(chunk)
	return chunk

func update_viewpoint(pos: Vector3):
	var snapped_pos = pos.snapped(Vector3(snap_size, 1, snap_size))
	snapped_pos.y = 0
	$Meshes.position = snapped_pos

#func _process(delta):
#	update_core(get_node("%Player").global_position)
