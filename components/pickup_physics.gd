extends RigidBody3D
class_name PickupPhysics

signal object_grabbed(object)
signal object_released(object)

## Input -> Process variables
var grabbing : bool = false
var grab_time : int = 0
var grabbed : bool = false
var screen_relative : Vector2 = Vector2.ZERO
var mouse_world : Vector3 = Vector3.ZERO


func _ready():
	_connect_signals()


func _connect_signals():
	if !input_event.is_connected(self._on_input_event):
		input_event.connect(self._on_input_event)


## Handles Direct input against the physics object.
## Use only for object targeting
## Fires for all inputs that connect to physics object.
func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if !grabbing and !grabbed:
				grabbing = true
				grab_time = Time.get_ticks_msec()


## Handles all Input regardless of positioning in relation to physics object.
## Use for handling states and gathering directional inputs.
## Fires for all inputs
func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == 1 \
	and !event.pressed:
		if grabbing:
			grabbing = false
		if grabbed:
			grabbed = false
			emit_signal("object_released", self)


func _update_mouse_world():
	var mouse_pos := get_viewport().get_mouse_position()
	var cam := get_viewport().get_camera_3d()
	var origin := cam.project_ray_origin(mouse_pos)
	var end := origin + cam.project_ray_normal(mouse_pos) * cam.far
	var query := PhysicsRayQueryParameters3D.create(origin, end, 16)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if !result.is_empty():
		mouse_world = result["position"]
		print(mouse_world)


func _physics_process(delta):
	if (grabbing and !grabbed) and Time.get_ticks_msec() - grab_time > 100:
		grabbed = true
		emit_signal("object_grabbed", self)
	if grabbed:
		## Check if Mouse Velocity is actually moving
		if Input.get_last_mouse_velocity().length_squared() > 2:
			_update_mouse_world()
			var flattened_target : Vector3 = Vector3(
				mouse_world.x,
				position.y,
				mouse_world.z
			)
			position = position.lerp(flattened_target, 5 * delta)
