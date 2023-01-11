extends StaticBody3D

@export var chunk_size = 64
@export var chunk_distance = 2
@export var source: Node
@export var max_chunks = 50

var _loaded_chunks = {}
var _to_load = []
var _last_viewpoint = null
var _actual_chunk_size

func _ready():
	_actual_chunk_size = chunk_size * source.resolution

func add_node(pos: Vector2):
	var node = CollisionShape3D.new()
	node.position = Vector3(pos.x, 0, pos.y)
	var shape = HeightMapShape3D.new()
	shape.map_width = _actual_chunk_size + 1
	shape.map_depth = _actual_chunk_size + 1
	var cs = Vector2(chunk_size, chunk_size)
	shape.map_data = source.get_area_height(Rect2(pos - cs/2, cs+Vector2(1, 1)/source.resolution))
	node.shape = shape
	node.scale = Vector3(1.0/source.resolution, 1, 1.0/source.resolution)
	_loaded_chunks[pos] = node
	add_child(node)

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
	

func _process(delta):
	if _to_load.is_empty() or not source.is_ready:
		return
	var pos = _to_load.pop_back()
	add_node(pos)
	
	if _loaded_chunks.size() > max_chunks:
		remove_furthest

func update_viewpoint(pos3):
	var pos = Vector2(pos3.x, pos3.z)
	var snapped_viewpoint = pos.snapped(Vector2(chunk_size, chunk_size))
	if _last_viewpoint == snapped_viewpoint:
		return
	_last_viewpoint = snapped_viewpoint
	_to_load = []
	var dd = chunk_distance * chunk_size
	for x in range(snapped_viewpoint.x - dd, snapped_viewpoint.x + dd, chunk_size):
		for y in range(snapped_viewpoint.y - dd, snapped_viewpoint.y + dd, chunk_size):
			var v = Vector2(x, y)
			if not (v in _loaded_chunks):
				_to_load.append(v)
	_to_load.sort_custom(func(a, b): return snapped_viewpoint.distance_squared_to(a) > snapped_viewpoint.distance_squared_to(b))
	

