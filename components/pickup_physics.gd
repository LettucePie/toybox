extends RigidBody3D
class_name PickupPhysics

signal object_grabbed(object, hold)
signal object_released(object)

## Usersetting variables
## Quick Drag is the function to pickup and immediately move something.
## It will also use the PickupRay component if one is attached.
var quick_drag : bool = true
## How far you have to drag within the grab_fast timeframe to activate \
## Quick Drag.
var quick_drag_sensitivity : int = 112

## Input -> Process variables
var grabbing : bool = false
var grab_time : int = 0
var grab_mouse_pos : Vector2 = Vector2.ZERO
var grabbed_fast : bool = false
var grabbed_long : bool = false
var target_y : float = 0.0
var mouse_relative : Vector2 = Vector2.ZERO
## Control Input -> Process variables
var menu_mode : bool = false
var mouse_offset : Vector2 = Vector2.ZERO
var control_mode_dampener : int = 0
var translate_only : bool = false
var vertical_only : bool = false
var rotate_only : bool = false


func _ready():
	_connect_signals()


func _connect_signals():
	if !input_event.is_connected(self._on_input_event):
		input_event.connect(self._on_input_event)


####
#### States
####
func grab_object(tf : bool):
	if tf:
		grabbed_fast = true
		emit_signal("object_grabbed", self, false)
		freeze = true
	else:
		grabbing = false
		grabbed_fast = false
		grabbed_long = false
		menu_mode = false
		set_control_mode("clear", false)
		emit_signal("object_released", self)
		mouse_offset = Vector2.ZERO
		grab_mouse_pos = Vector2.ZERO
		freeze = false


func hold_object(tf : bool):
	if tf:
		grabbed_long = true
		menu_mode = true
		grabbed_fast = false
		emit_signal("object_grabbed", self, true)
		freeze = true
	else:
		grabbing = false
		grabbed_long = false
		menu_mode = false
		set_control_mode("clear", false)
		grabbed_fast = false
		emit_signal("object_released", self)
		mouse_offset = Vector2.ZERO
		grab_mouse_pos = Vector2.ZERO
		freeze = false


func set_control_mode(mode : String, get_offset : bool):
	if get_offset:
		mouse_offset = get_viewport().get_mouse_position() - grab_mouse_pos
	control_mode_dampener = 30
	mouse_relative = Vector2.ZERO
	if mode == "translate":
		translate_only = true
		vertical_only = false
		rotate_only = false
	elif mode == "vertical":
		target_y = position.y
		translate_only = false
		vertical_only = true
		rotate_only = false
	elif mode == "rotate":
		translate_only = false
		vertical_only = false
		rotate_only = true
	elif mode == "clear" or mode == "":
		translate_only = false
		vertical_only = false
		rotate_only = false


####
#### Calculations
####

## Gets the Mouse Position on screen and converts to "floor" position \
## using intersect_ray
func _get_mouse_world(offset : Vector2) -> Vector3:
	var world_pos : Vector3 = position
	var mouse_pos := get_viewport().get_mouse_position() - offset
	var cam := get_viewport().get_camera_3d()
	var origin := cam.project_ray_origin(mouse_pos)
	var end := origin + cam.project_ray_normal(mouse_pos) * cam.far
	var query := PhysicsRayQueryParameters3D.create(origin, end, 16)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if !result.is_empty():
		world_pos = result["position"]
	return world_pos


####
#### Input
####

## Handles Direct input against the physics object.
## Use only for object targeting
## Fires for all inputs that connect to physics object.
func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if !grabbing and (!grabbed_long or !grabbed_fast):
				grabbing = true
				grab_time = Time.get_ticks_msec()
				grab_mouse_pos = get_viewport().get_mouse_position()


## Handles all Input regardless of positioning in relation to physics object.
## Use for handling states and gathering directional inputs.
## Fires for all inputs
func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == 1 \
	and !event.pressed:
		if grabbing:
			grabbing = false
		if grabbed_fast:
			grab_object(false)
		if grabbed_long:
			## Reset grab_mouse_pos to new mouse position post control
			if translate_only or vertical_only or rotate_only:
				grab_mouse_pos = event.position - mouse_offset
			## Call Hold_object(false) when done with menu.
			## until then only emit the release signal.
			emit_signal("object_released", self)
			translate_only = false
			vertical_only = false
			rotate_only = false
	if event is InputEventMouseMotion and rotate_only:
		mouse_relative = event.relative


####
#### Physics Applications
####

## Used just to horizontally move an object. X and Z axis.
func _translate_movement(delta, offset):
	## Check if Mouse Velocity is actually moving
	if Input.get_last_mouse_velocity().length_squared() > 2:
		var mouse_world : Vector3 = _get_mouse_world(offset)
		var flattened_target : Vector3 = Vector3(
			mouse_world.x,
			position.y,
			mouse_world.z
		)
		var speed : float = 5.0 * delta
		if grabbed_long and control_mode_dampener > 0:
			speed = 2.5 * delta
		position = position.lerp(flattened_target, speed)


func _vertical_movement(delta):
	var mouse_pos = get_viewport().get_mouse_position() - mouse_offset
	var z_depth = get_viewport().get_camera_3d().position.distance_to(
		self.position)
	var target_y = get_viewport().get_camera_3d().project_position(
		mouse_pos, z_depth).y
	var speed : float = 5.0 * delta
	if grabbed_long and control_mode_dampener > 0:
		speed = 2.5 * delta
	position.y = lerp(position.y, target_y, speed)


func _rotate_movement(delta):
	## Dial around the Camera Forward by the mouse relative...
	## uhh... like start with the camera's right direction, and use the \
	## cameras forward direction as an imaginary pin. rotate the cam right \
	## to the same angle that mouse relative is, to match the 2d position \
	## of the mouse cursor to an interpreted "mouse relative forward" axis.
	## Then rotate that "mouse relative forward" -90 degrees by that \
	## imaginary pin to get the sort of north and south pole of the mouse \
	## relative input.
	var cam_forward := get_viewport().get_camera_3d() \
		.global_basis * Vector3.FORWARD
	var cam_right := get_viewport().get_camera_3d() \
		.global_basis * Vector3.RIGHT
	var cam_dialed : Vector3 = cam_right.rotated(
		cam_forward,
		mouse_relative.angle()
	)
	var mouse_relative_axis := cam_dialed.rotated(cam_forward, PI / -2)
	## Horizontal == spin override
	if abs(mouse_relative.x) > 0 and abs(mouse_relative.y) < 2:
		mouse_relative_axis = Vector3.UP
		if mouse_relative.x < 0:
			mouse_relative_axis = Vector3.DOWN
	## Gather strength by getting mouse_relative length()
	rotate(mouse_relative_axis, mouse_relative.length() * delta)
	mouse_relative = mouse_relative.lerp(Vector2.ZERO, 0.33)


func _physics_process(delta):
	## Checking to see if mouse is being held down on object, and neither \
	## the quick drag or hold and control thresholds have been reached.
	if grabbing and (!grabbed_fast and !grabbed_long):
		## Building hold_time and drag_distance variables
		var hold_time : int = Time.get_ticks_msec() - grab_time
		var drag_distance : float = get_viewport().get_mouse_position()\
		.distance_squared_to(grab_mouse_pos)
		if drag_distance >= quick_drag_sensitivity and hold_time > 60:
			grab_object(true)
		elif drag_distance < quick_drag_sensitivity and hold_time > 120:
			hold_object(true)
	## Apply quick-drag logic if true
	if grabbed_fast:
		_translate_movement(delta, Vector2.ZERO)
	## Apply hold and control logic otherwise.
	elif grabbed_long:
		## Suspend location, only affecting if translate, vertical, or rotate
		if translate_only:
			_translate_movement(delta, mouse_offset)
		if vertical_only:
			_vertical_movement(delta)
		if rotate_only:
			_rotate_movement(delta)
	## End-Frame Maintenance
	if control_mode_dampener > 0:
		control_mode_dampener -= 1
