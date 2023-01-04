extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Fps.text = "fps: {count}".format({"count": Engine.get_frames_per_second()})
	var pos = get_node("%Player").global_position
	$Pos.text = "x: {x}\ny: {y}\nz: {z}".format({"x": pos.x, "y": pos.y, "z": pos.z})
