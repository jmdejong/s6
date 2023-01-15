@tool
extends Node2D

@export var area = Rect2(0, 0, 256, 256)
@export var spread = 64
@export var nsegments = 6
@export var nblades = 64
@export var colorspread = 0.3
@export var seed : float = 1 :
	set(value):
		seed = value
		print("seed changed")
		_set_seed(value)

func quad_bezier(p0, p1, p2, t):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	return q0.lerp(q1, t)

func _draw():
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(seed)
	
	for i in range(nblades):
		var base = Vector2(rng.randf_range(0.1, 0.9) * area.size.x, area.end.y)
		var w = rng.randf_range(2, 8)
		var h = rng.randf_range(area.size.y / 2, area.size.y)
		var end = Vector2(rng.randf_range(max(area.position.x, base.x - spread), min(area.end.x, base.x  + spread)), base.y - h)
		var control = Vector2(rng.randf_range(max(area.position.x, base.x - spread / 2), min(area.end.x, base.x  + spread / 2)), base.y - h * rng.randf_range(0.5, 1.0))
		var poly = PackedVector2Array()
		for p in range(nsegments * 2 + 1):
			var t = min(p, 2*nsegments-p) / float(nsegments)
			var b = int(p > nsegments) * 2 - 1
			var pos = quad_bezier(base, control, end, t)
			poly.append(Vector2(pos.x + w * b * (1.0 - t/2), pos.y))

		draw_colored_polygon(
			poly, 
			Color(rng.randf() * colorspread, 1.0 - rng.randf() * colorspread, rng.randf() * colorspread)
		)

func _process(delta):
	queue_redraw()

func _set_seed(value):
	print("seed changed fn")
	queue_redraw()
