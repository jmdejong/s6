extends CharacterBody3D


const MOUSE_SENSITIVITY = 0.003
const speed = 3
const sprint_speed = 100
const gravity = 9.81
const jump_speed = 10

var gravity_enabled: bool = false



signal viewpoint_changed(pos: Vector3)

func _physics_process(delta):
	var input_movement = Input.get_vector("left", "right", "forwards", "backwards")
	var s = speed if not Input.is_action_pressed("sprint") else sprint_speed
	var movement = (Vector3(input_movement.y, 0, -input_movement.x) * s).rotated(Vector3(0, 1, 0), self.rotation.y)
	if gravity_enabled:
		movement.y = velocity.y - gravity*delta
		if Input.is_action_pressed("up") and is_on_floor():
			movement.y = s
	else:
		movement.y = s * (float(Input.is_action_pressed("up")) - float(Input.is_action_pressed("down")))
	velocity = movement

	move_and_slide()
	
	viewpoint_changed.emit(position)

func _input(event):
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("gravity"):
		gravity_enabled = not gravity_enabled

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# $Head.rotate_z(event.relative.y * MOUSE_SENSITIVITY)
		$Head.rotation.x = clamp($Head.rotation.x - event.relative.y * MOUSE_SENSITIVITY, -PI/2, PI/2)
		# $Head.rotation.z = clamp($Head.rotation.z, -PI/2, PI/2)
		# print($Head.rotation)
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)

