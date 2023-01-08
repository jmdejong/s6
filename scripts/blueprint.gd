extends Node

@export var aabb = AABB(Vector3(-2048, -256, -2048), Vector3(4096, 1024, 4096))
@export var _shore_offset = 1024
@export var base_height = -64
@export var resolution = 1

var _area
var height_texture
var normal_texture
var _heightmap_image
var grass_density_texture
var current_texture
var is_ready = false
signal _creation_done

func _ready():
	_area = Rect2(aabb.position.x, aabb.position.z, aabb.size.x, aabb.size.z)
	
	_initialize_view($HeightView, {"shore_offset": _shore_offset, "base_height": base_height})
	_initialize_view($NormalView, {"shore_offset": _shore_offset, "base_height": base_height})

	await RenderingServer.frame_post_draw
	height_texture = $HeightView.get_texture()
	_heightmap_image = height_texture.get_image()
	normal_texture = $NormalView.get_texture()
	_initialize_view($GrassView, {"height_input":  height_texture, "normal_input": normal_texture})
	$GrassView.render_target_update_mode = 1

	_initialize_view($CurrentTextureView, {"height_input":  height_texture, "normal_input": normal_texture})
	$CurrentTextureView.render_target_update_mode = 1

	await RenderingServer.frame_post_draw
	grass_density_texture = $GrassView.get_texture()
	current_texture = $CurrentTextureView.get_texture()
	is_ready = true
	_creation_done.emit()

func _initialize_view(viewport, parameters):
	viewport.size = _area.size * resolution
	viewport.get_node("Image").size = _area.size * resolution
	viewport.get_node("Image").material.set_shader_parameter("area_min", aabb.position)
	viewport.get_node("Image").material.set_shader_parameter("area_size", aabb.size)
	for key in parameters:
		viewport.get_node("Image").material.set_shader_parameter(key, parameters[key])

func await_creation():
	if not is_ready:
		await _creation_done


func water_height():
	return -0.01

func get_height_raw(x, y):
	var ch = _heightmap_image.get_pixel(x, y)
	return (ch.r + ch.g/255) * aabb.size.y + aabb.position.y

func get_all_heights():
	return get_area_height(_area)
	# var heightdata = PackedFloat32Array()
	# heightdata.resize(_area.size.x * resolution * _area.size.y * resolution)
	# var i = 0
	# for y in range(0, _area.size.y * resolution):
	# 	for x in range(0, _area.size.x * resolution):
	# 		var ch = _heightmap_image.get_pixel(x, y)
	# 		heightdata[i] = (ch.r + ch.g/255) * aabb.size.y + aabb.position.y
	# 		i += 1
	# return heightdata


func get_area_height(sub_area):
	var pixel_area = Rect2((sub_area.position - _area.position) * resolution, sub_area.size * resolution)
	var used_pixel_area = pixel_area.intersection(Rect2(Vector2(0, 0), _area.size * resolution)) #Rect2(used_area.position - area.position) * resolution, used_area.size * resolution)
	var heightdata = PackedFloat32Array()
	heightdata.resize(pixel_area.get_area())
	heightdata.fill(base_height)
	# print("area height ", sub_area, pixel_area, used_pixel_area)
	# used_area = sub_area.instersection(_area)
	# used_pixel_area = Rect2(used_area.position - area.position) * resolution, used_area.size * resolution)
	for y in range(used_pixel_area.position.y, used_pixel_area.end.y):
		for x in range(used_pixel_area.position.x, used_pixel_area.end.x):
			var ch = _heightmap_image.get_pixel(x, y)
			heightdata[x - used_pixel_area.position.x + (y - used_pixel_area.position.y) * pixel_area.size.x ] = (ch.r + ch.g/255) * aabb.size.y + aabb.position.y
	return heightdata


func __heightmap_get(p):
	var ch = _heightmap_image.get_pixel(int(p.x), int(p.y))
	return (ch.r + ch.g/255) * aabb.size.y + aabb.position.y

func get_height(p):
	if not _area.has_point(p):
		return base_height
	var cc = (p - _area.position) * resolution
	var xy = floor(cc)
	var uv = cc - xy
	var ch = __heightmap_get(xy) * (1-uv.x) * (1-uv.y) \
		+ __heightmap_get(xy + Vector2(1, 0)) * (uv.x) * (1-uv.y) \
		+ __heightmap_get(xy + Vector2(0, 1)) * (1-uv.x) * (uv.y) \
		+ __heightmap_get(xy + Vector2(1, 1)) * (uv.x) * (uv.y)
	return ch



